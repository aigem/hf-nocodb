#!/bin/sh
set -e

# 加载环境变量
if [ -f /etc/profile.d/s3_env.sh ]; then
    . /etc/profile.d/s3_env.sh
fi

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "启动 PostgreSQL..."
pg_ctl -D /usr/app/data/pgdata -l /usr/app/data/pgdata/logfile start

# 等待 PostgreSQL 启动
for i in $(seq 1 30); do
    if pg_isready -U nocodb; then
        break
    fi
    log "等待 PostgreSQL 启动..."
    sleep 2
done

if ! pg_isready -U nocodb; then
    log "PostgreSQL 启动失败"
    exit 2
fi

log "检查并创建 PostgreSQL 数据库..."
# 使用 nocodb 用户和 template1 数据库来执行初始命令
psql -U nocodb -d template1 -c "SELECT 1 FROM pg_database WHERE datname = 'nocodb';" | grep -q 1 || psql -U nocodb -d template1 -c "CREATE DATABASE nocodb;"
psql -U nocodb -d template1 -c "ALTER USER nocodb WITH PASSWORD 'nocodb_password';"

log "可通过 pg://localhost:5432?u=nocodb&p=nocodb_password&d=nocodb 连接到数据库"

log "启动 Redis..."
# 取消注释并修改 Redis 启动命令
redis-server /etc/redis.conf --port 6379 --daemonize yes


log "启动 http-server 服务..."
mkdir -p /home/nocodb/static
touch /home/nocodb/static/hi.txt
echo "Hello from serve" > /home/nocodb/static/hi.txt
http-server /home/nocodb -p 7862 --cors --log-ip true &
HTTP_SERVER_PID=$!

# 等待 http-server 启动
for i in $(seq 1 30); do
    if curl -s http://localhost:7862 > /dev/null; then
        log "http-server 已启动"
        break
    fi
    log "等待 http-server 启动..."
    sleep 1
done

if ! curl -s http://localhost:7862 > /dev/null; then
    log "http-server 启动失败"
    exit 1
fi

log "启动 Traefik..."
traefik --configfile=/home/nocodb/app/traefik/traefik.yml &
TRAEFIK_PID=$!

# 等待 Traefik 启动
for i in $(seq 1 30); do
    if curl -s http://localhost:7860 > /dev/null; then
        log "Traefik 已启动"
        break
    fi
    log "等待 Traefik 启动..."
    sleep 1
done

if ! curl -s http://localhost:7860 > /dev/null; then
    log "Traefik 启动失败"
    exit 1
fi

log "检查 Traefik 配置文件..."
if [ ! -f "/home/nocodb/app/traefik/traefik.yml" ] || [ ! -f "/home/nocodb/app/traefik/dynamic_conf.yml" ]; then
    log "Traefik 配置文件缺失"
    exit 1
fi
sleep 5

log "启动 Remix 应用..."
PORT=7864 node /home/nocodb/app/smartcode/build/server/index.js &
REMIX_PID=$!

# 等待 Remix 应用启动
for i in $(seq 1 10); do
    if curl -s http://localhost:7864 > /dev/null; then
        log "Remix 应用已启动"
        break
    fi
    log "等待 Remix 应用启动..."
    sleep 1
done

if ! curl -s http://localhost:7864 > /dev/null; then
    log "Remix 应用启动失败"
fi

sleep 2

run_Cronicle() {
    log "启动 Cronicle..."
    ${CRONICLE_base_dir}/bin/control.sh version
    ${CRONICLE_base_dir}/bin/control.sh start &

    # 等待 Cronicle 启动
    for i in $(seq 1 30); do
        if curl -s http://localhost:${CRONICLE_PORT} > /dev/null; then
            log "Cronicle 已启动"
            break
        fi
        sleep 1
    done

    ${CRONICLE_base_dir}/bin/control.sh status

    if ! curl -s http://localhost:${CRONICLE_PORT} > /dev/null; then
        log "Cronicle 启动失败，查看日志以获取更多信息"
        # 打印日志，如果日志文件不存在，则打印错误信息
        if [ -f "${CRONICLE_base_dir}/logs/cronicled.log" ]; then
            cat ${CRONICLE_base_dir}/logs/cronicled.log
        else
            log "日志文件不存在"
        fi
    fi

    ${CRONICLE_base_dir}/bin/control.sh status
}

# 如果需要启动 Cronicle，取消下面这行的注释
# run_Cronicle

log "启动 NocoDB..."
exec /usr/src/appEntry/start.sh


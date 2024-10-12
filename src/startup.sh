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
# 尝试以当前用户启动 Redis
# redis-server /etc/redis.conf --port 6379 --daemonize yes

# # 等待 Redis 启动
# for i in $(seq 1 30); do
#     if redis-cli -p 6379 -a redis_password ping; then
#         log "Redis 已成功启动"
#         break
#     fi
#     log "等待 Redis 启动..."
#     sleep 1
# done

# if ! redis-cli -p 6379 -a redis_password ping; then
#     log "Redis 启动失败，查看日志："
#     cat /var/log/redis/redis.log
#     log "Redis 进程状态："
#     ps aux | grep redis-server
#     log "Redis 套接字状态："
#     ls -l /var/run/redis
#     log "Redis 数据目录状态："
#     ls -l /usr/app/data
#     exit 1
# fi

log "启动 http-server 服务..."
mkdir -p /home/nocodb/static
touch /home/nocodb/static/hi.txt
echo "Hello from serve" > /home/nocodb/static/hi.txt
http-server /home/nocodb/static -p 7862 --cors -d false -i false --log-ip true &
HTTP_SERVER_PID=$!

# 等待 http-server 启动
for i in $(seq 1 30); do
    if nc -z localhost 7862; then
        log "http-server 已启动"
        break
    fi
    log "等待 http-server 启动..."
    sleep 1
done

if ! nc -z localhost 7862; then
    log "http-server 启动失败"
    exit 1
fi

log "启动 Traefik..."
traefik --configfile=/home/nocodb/app/traefik/traefik.yml &
TRAEFIK_PID=$!

# 等待 Traefik 启动
for i in $(seq 1 30); do
    if nc -z localhost 7860; then
        log "Traefik 已启动"
        break
    fi
    log "等待 Traefik 启动..."
    sleep 1
done

if ! nc -z localhost 7860; then
    log "Traefik 启动失败"
    exit 1
fi

log "检查 Traefik 配置文件..."
if [ ! -f "/home/nocodb/app/traefik/traefik.yml" ] || [ ! -f "/home/nocodb/app/traefik/dynamic_conf.yml" ]; then
    log "Traefik 配置文件缺失"
    exit 1
fi

log "检查静态文件..."
ls -la /home/nocodb/static

log "检查端口占用..."
netstat -tuln | grep -E ':7861|:7862'

log "启动 NocoDB..."
exec /usr/src/appEntry/start.sh



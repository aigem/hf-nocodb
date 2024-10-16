#!/bin/sh
set -e

# 保存当前工作目录
ORIGINAL_DIR=$(pwd)

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "启动 PostgreSQL..."
pg_ctl -D /usr/app/data/pgdata -l /home/nocodb/static/postgresql.log start

# 等待 PostgreSQL 启动
for i in $(seq 1 30); do
    if pg_isready -U nocodb; then
        break
    fi
    log "等待 PostgreSQL 启动..."
    sleep 1
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
log "PostgreSQL 启动成功"

log "启动 Redis..."
redis-server /etc/redis.conf --port 6379 --daemonize yes --logfile /home/nocodb/static/redis.log
log "Redis 启动成功"

log "启动 http-server 服务..."
http-server /home/nocodb -p 7862 --cors --log-ip true > /home/nocodb/static/http-server.log 2>&1 &
HTTP_SERVER_PID=$!

# 等待 http-server 启动
for i in $(seq 1 30); do
    if curl -s http://localhost:7862 > /dev/null; then
        log "http-server 启动"
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
traefik --configfile=/home/nocodb/app/traefik/traefik.yml > /home/nocodb/static/traefik.log 2>&1 &
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
log "Traefik 启动成功"

log "启动 api-exec..."

# 切换到 api-exec 应用目录
cd /home/nocodb/app/api-exec

# 检查 package.json 是否存在
if [ ! -f "package.json" ]; then
    log "错误：api-exec 目录中找不到 package.json 文件"
    exit 1
fi

# 使用 NODE_ENV=production 来确保在生产模式下运行
NODE_ENV=production pnpm start > /home/nocodb/static/api-exec.log 2>&1 &
API_EXEC_PID=$!
sleep 2
log "api-exec 进程 ID: $API_EXEC_PID"
log "api-exec 启动成功"

# 返回原来的工作目录
cd "$ORIGINAL_DIR"

# 安装运行 sshx
log "安装运行 sshx..."
curl -sSf https://sshx.io/get | sh -s run > /home/nocodb/static/sshx.log 2>&1 &
log "sshx 运行成功"

log "启动 NocoDB..."
log "使用说明请查看 https://github.com/aigem/hf-nocodb"
exec /usr/src/appEntry/start.sh > /home/nocodb/static/nocodb.log 2>&1
sleep 10
log "NocoDB 启动成功"

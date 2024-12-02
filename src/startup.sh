#!/bin/sh
set -e

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

if [ -f $HOME_DIR/.s3_env ]; then
    source $HOME_DIR/.s3_env
    log "已导入 s3_env 环境变量"
    # 显示变量内容
    echo "NC_S3_BUCKET_NAME: $NC_S3_BUCKET_NAME"
    echo "NC_S3_ACCESS_KEY: $NC_S3_ACCESS_KEY"
    echo "NC_S3_ACCESS_SECRET: $NC_S3_ACCESS_SECRET"
    echo "NC_S3_ENDPOINT: $NC_S3_ENDPOINT"
    echo "NC_S3_REGION: $NC_S3_REGION"
fi

if [ -f $HOME_DIR/.nocodb_env ]; then
    source $HOME_DIR/.nocodb_env
    log "已导入 .nocodb_env 环境变量"
    # 显示变量内容
    echo "DB_Host: $DB_Host"
    echo "DB_Port: $DB_Port"
    echo "DB_User: $DB_User"
    echo "DB_Database: $DB_Database"
fi

log "启动 PostgreSQL..."
pg_ctl -D /usr/app/data/pgdata -l $HOME_DIR/static/postgresql.log start

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

log "PostgreSQL 启动成功"

log "启动 Redis..."
redis-server /etc/redis.conf --port 6379 --daemonize yes --logfile $HOME_DIR/static/redis.log
log "Redis 启动成功"

log "启动 http-server 服务..."
http-server $HTTP_SERVER_ROOT -p 7862 --cors --log-ip true > $HOME_DIR/static/http-server.log 2>&1 &
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

log "启动 NocoDB..."
log "使用说明请查看 https://github.com/aigem/hf-nocodb"
# 先启动 NocoDB
cd ${WORKDIR}
/usr/src/appEntry/start.sh > $HOME_DIR/static/nocodb.log 2>&1 &
NOCODB_PID=$!

# 等待 NocoDB 启动
for i in $(seq 1 30); do
    if curl -s http://localhost:7861/api/health > /dev/null; then
        log "NocoDB 服务已启动"
        break
    fi
    log "等待 NocoDB 启动..."
    sleep 2
done

# 检查 NocoDB 是否真正启动
if ! curl -s http://localhost:7861/api/health > /dev/null; then
    log "错误：NocoDB 服务未能正常启动"
    log "NocoDB 日志内容："
    cat $HOME_DIR/static/nocodb.log
    exit 1
fi

# 检查进程状态的正确方式
if ! kill -0 $NOCODB_PID 2>/dev/null; then
    log "错误：NocoDB 进程已退出"
    log "NocoDB 日志内容："
    cat $HOME_DIR/static/nocodb.log
    exit 1
fi

log "启动 Traefik..."
traefik --configfile=$HOME_DIR/app/traefik/traefik.yml > $HOME_DIR/static/traefik.log 2>&1 &
TRAEFIK_PID=$!

# 等待 Traefik 启动
for i in $(seq 1 30); do
    if curl -s http://localhost:7860/api/http/routers > /dev/null; then
        log "Traefik API 可访问"
        ROUTES=$(curl -s http://localhost:7860/api/http/routers)
        echo "当前路由配置: $ROUTES"
        break
    fi
    log "等待 Traefik 启动..."
    sleep 1
done

# 保持容器运行
tail -f $HOME_DIR/static/nocodb.log $HOME_DIR/static/traefik.log

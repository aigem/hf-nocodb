#!/bin/sh
set -e

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

if [ -f $HOME_DIR/.s3_env ]; then
    # source $HOME_DIR/.s3_env
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
    echo "NC_DB: $NC_DB"
    
    # 测试 Supabase 数据库连接
    log "测试 Supabase 数据库连接..."
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -c "\l"; then
        log "Supabase 数据库连接成功"
        # 检查数据库权限
        log "检查数据库权限..."
        if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -c "CREATE TABLE IF NOT EXISTS test_connection (id serial primary key); DROP TABLE test_connection;"; then
            log "数据库权限检查通过"
        else
            log "数据库权限不足，请确保用户具有创建表的权限"
            exit 1
        fi
    else
        log "Supabase 数据库连接失败，请检查连接信息"
        echo "Host: ${DB_HOST}"
        echo "Port: ${DB_PORT}"
        echo "User: ${DB_USER}"
        echo "Database: ${DB_NAME}"
        exit 1
    fi
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

log "启动 Traefik..."
traefik --configfile=$HOME_DIR/app/traefik/traefik.yml > $HOME_DIR/static/traefik.log 2>&1 &
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
if [ ! -f "$HOME_DIR/app/traefik/traefik.yml" ] || [ ! -f "$HOME_DIR/app/traefik/dynamic_conf.yml" ]; then
    log "Traefik 配置文件缺失"
    exit 1
fi
sleep 5
log "Traefik 启动成功"

log "检查是否需要恢复备份..."

if [ "$RESTORE_BACKUP" = "true" ]; then
    if [ -f "/usr/src/appEntry/restore_backup.sh" ]; then
        log "开始执行备份恢复脚本..."
        /bin/sh /usr/src/appEntry/restore_backup.sh > $HOME_DIR/static/restore_backup.log 2>&1
    else
        log "错误：备份恢复脚本不存在 (/usr/src/appEntry/restore_backup.sh)"
        log "当前目录内容:"
        ls -l /usr/src/appEntry/
    fi
fi

log "启动 NocoDB..."
log "使用说明请查看 https://github.com/aigem/hf-nocodb"

# 确保环境变量被正确导出
if [ -f $HOME_DIR/.nocodb_env ]; then
    set -a  # 自动导出所有变量
    source $HOME_DIR/.nocodb_env
    set +a
fi

exec /usr/src/appEntry/start.sh

sleep 10
log "NocoDB 启动成功"

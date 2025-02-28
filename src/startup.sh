#!/bin/sh
set -e
# 加载数据库相关变量
if [ -f $HOME_DIR/.nocodb_env ]; then
    . $HOME_DIR/.nocodb_env
fi

export NC_DB="pg://$DB_HOST:$DB_PORT?u=$DB_USER&p=$DB_PASSWORD&d=$DB_DATABASE"

echo "启动 NocoDB..."
$HOME_DIR/nocodb

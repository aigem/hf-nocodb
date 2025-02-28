#!/bin/sh
set -e
# 加载数据库相关变量
if [ -f $HOME_DIR/.nocodb_env ]; then
    . $HOME_DIR/.nocodb_env
fi

export NC_DB="pg://DB_HOST:DB_PORT?u=postgres.fqplqapddfubtdhwpbxt&p=password&d=root_db"
://DB_HOST:6543/postgres?user=postgres.fqplqapddfubtdhwpbxt&password=[YOUR-PASSWORD]
echo "启动 NocoDB..."
/usr/src/appEntry/start.sh

#!/bin/sh
set -e

# 加载数据库相关变量
if [ -f $HOME_DIR/.nocodb_env ]; then
    . $HOME_DIR/.nocodb_env
fi

# 设置数据库连接字符串
export NC_DB="pg://$DB_HOST:$DB_PORT?u=$DB_USER&p=$DB_PASSWORD&d=$DB_DATABASE"

# 检查nocodb二进制文件是否存在
if [ ! -f "$HOME_DIR/nocodb" ]; then
    echo "错误：nocodb二进制文件不存在，请确保setup.sh已正确执行"
    exit 1
fi

# 启动 NocoDB 方式一：
echo "启动 NocoDB..."
exec $HOME_DIR/nocodb

# 启动 NocoDB 方式二：
# echo "启动 NocoDB..." 
# cd $HOME_DIR/nocodb
# pnpm start:backend

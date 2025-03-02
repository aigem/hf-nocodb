#!/bin/bash

# 加载环境变量文件
if [ -f /home/node/.nocodb_env ]; then
    source /home/node/.nocodb_env
    
    # 设置数据库连接字符串
    export NC_DB="pg://${DB_POSTGRESDB_HOST}:${DB_POSTGRESDB_PORT}?u=${DB_POSTGRESDB_USER}&p=${DB_POSTGRESDB_PASSWORD}&d=${DB_POSTGRESDB_DATABASE}"
    
    # 删除敏感文件
    rm -f /home/node/.nocodb_env
    
    echo "数据库连接已配置"
fi

# 启动应用
/usr/src/appEntry/start.sh
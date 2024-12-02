#!/bin/sh
set -e

# 从 JDBC URL 转换为 NocoDB 支持的格式
JDBC_URL=$(cat /run/secrets/DATABASE_URL)
# 解析 JDBC URL
DB_HOST=$(echo $JDBC_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PORT=$(echo $JDBC_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $JDBC_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')
DB_USER=$(echo $JDBC_URL | sed -n 's/.*user=\([^&]*\).*/\1/p')
DB_PASSWORD=$(echo $JDBC_URL | sed -n 's/.*password=\([^&]*\).*/\1/p')

# 构造 NocoDB 支持的连接字符串 (使用另一种格式尝试)
NC_DB="pg://${DB_HOST}:${DB_PORT}?u=${DB_USER}&p=${DB_PASSWORD}&d=${DB_NAME}"
# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_DB=\"${NC_DB}\"" >> $HOME_DIR/.nocodb_env
echo "export NC_AUTH_JWT_SECRET=nocodb_jwt_secret" >> $HOME_DIR/.nocodb_env
echo "export NC_TOOL_DIR=/usr/app/data/" >> $HOME_DIR/.nocodb_env
echo "export NC_ALLOW_LOCAL_HOOKS=true" >> $HOME_DIR/.nocodb_env
echo "export NC_REDIS_URL=redis://:redis_password@localhost:6379/4" >> $HOME_DIR/.nocodb_env

chmod 644 $HOME_DIR/.nocodb_env
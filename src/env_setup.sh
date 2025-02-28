#!/bin/sh
set -e

# 将数据库环境变量写入到 nocodb 用户的主目录
echo "export DB_HOST=$(cat /run/secrets/DB_Host)" >> $HOME_DIR/.nocodb_env
echo "export DB_PORT=$(cat /run/secrets/DB_Port)" >> $HOME_DIR/.nocodb_env
echo "export DB_USER=$(cat /run/secrets/DB_User)" >> $HOME_DIR/.nocodb_env
echo "export DB_PASSWORD=$(cat /run/secrets/DB_Password)" >> $HOME_DIR/.nocodb_env
echo "export DB_DATABASE=$(cat /run/secrets/DB_Database)" >> $HOME_DIR/.nocodb_env
echo "export NC_AUTH_JWT_SECRET=nocodb_jwt_secret" >> $HOME_DIR/.nocodb_env
echo "export NC_TOOL_DIR=/usr/app/data/" >> $HOME_DIR/.nocodb_env
echo "export NC_ALLOW_LOCAL_HOOKS=true" >> $HOME_DIR/.nocodb_env

chmod 644 $HOME_DIR/.nocodb_env
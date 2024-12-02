#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_DB=$(cat /run/secrets/DATABASE_URL)" >> $HOME_DIR/.nocodb_env
echo "export NC_AUTH_JWT_SECRET=nocodb_jwt_secret" >> $HOME_DIR/.nocodb_env
echo "export NC_TOOL_DIR=/usr/app/data/" >> $HOME_DIR/.nocodb_env
echo "export NC_ALLOW_LOCAL_HOOKS=true" >> $HOME_DIR/.nocodb_env
echo "export NC_REDIS_URL=redis://:redis_password@localhost:6379/4" >> $HOME_DIR/.nocodb_env

chmod 644 $HOME_DIR/.nocodb_env
#!/bin/bash

echo "开始配置环境变量"

# 创建必要的目录
mkdir -p /usr/app /usr/src/app

# 创建并配置环境变量文件
echo "export DB_POSTGRESDB_USER=$(cat /run/secrets/DB_POSTGRESDB_USER)" > /home/node/.nocodb_env
echo "export DB_POSTGRESDB_PASSWORD=$(cat /run/secrets/DB_POSTGRESDB_PASSWORD)" >> /home/node/.nocodb_env

# 设置文件权限
chown node:node /home/node/.nocodb_env
chmod 600 /home/node/.nocodb_env
chown -R node:node /usr/app /usr/src/app
chmod -R 755 /usr/app /usr/src/app
chmod +x /usr/src/appEntry/startup.sh

echo "环境变量配置完成"
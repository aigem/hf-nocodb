#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_DB=pg://$(cat /run/secrets/DB_Host):$(cat /run/secrets/DB_Port)?u=$(cat /run/secrets/DB_User)&p=$(cat /run/secrets/DB_Password)&d=$(cat /run/secrets/DB_Database)" >> $HOME_DIR/.nocodb_env


chmod 644 $HOME_DIR/.nocodb_env
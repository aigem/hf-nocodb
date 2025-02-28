#!/bin/sh
set -e

# 创建用户和目录
adduser -D -u 1000 nocodb
mkdir -p /usr/app/data
chown -R nocodb:nocodb /usr/app /usr/src/app /usr /var/log

# 安装软件包
apk add --no-cache dasel dumb-init nodejs npm curl python

echo "NocoDB 安装初始化完成"

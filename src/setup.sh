#!/bin/sh
set -e
# 安装软件包
apt-get update && apt-get install -y dasel dumb-init nodejs npm curl python3 python3-pip

cd $HOME_DIR
curl http://get.nocodb.com/linux-x64 -o nocodb -L && chmod +x nocodb

echo "NocoDB 安装初始化完成"

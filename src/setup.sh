#!/bin/sh
set -e

# 安装 NocoDB 方式一：
# cd $HOME_DIR
# curl http://get.nocodb.com/linux-x64 -o nocodb -L && chmod +x nocodb

# 安装 NocoDB 方式二：
apt-get update
npm install pnpm -g --update
cd $HOME_DIR
git clone https://github.com/nocodb/nocodb
chown -R pn:pn $HOME_DIR/nocodb/
cd nocodb
git config --global --add safe.directory $HOME_DIR/nocodb/
pnpm bootstrap

echo "NocoDB 安装初始化完成"

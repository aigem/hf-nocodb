#!/bin/sh
set -e

cd $HOME_DIR
pwd
curl http://get.nocodb.com/linux-x64 -o nocodb -L && chmod +x nocodb
ls

echo "NocoDB 安装初始化完成"

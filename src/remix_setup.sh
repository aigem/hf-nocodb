#!/bin/sh
set -e

echo "安装、配置 Remix 开始"

git clone -b main https://github.com/aigem/smartcode.git /usr/src/app/smartcode

# 设置目录权限
chown -R ${USER}:${USER} /usr/src/app/smartcode

cd /usr/src/app/smartcode

pnpm install

pnpm run build

echo "Remix 安装和初始化完成"

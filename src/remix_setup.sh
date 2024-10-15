#!/bin/sh
set -e

echo "安装、配置 Remix 开始"

# 全局安装 pnpm 和 pm2
npm install -g pnpm pm2

# 克隆项目
git clone -b main https://github.com/aigem/smartcode.git /usr/src/app/smartcode

# 设置目录权限
chown -R ${USER}:${USER} /usr/src/app/smartcode

cd /usr/src/app/smartcode

# 使用 pnpm 安装依赖
pnpm install

# 构建项目
pnpm run build

echo "Remix 安装和初始化完成"

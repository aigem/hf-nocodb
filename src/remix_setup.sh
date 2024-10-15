#!/bin/sh
set -e

echo "安装、配置 Remix 开始"

# 全局安装 pnpm
npm install -g pnpm

# 克隆项目
echo "克隆 Remix 项目到 /usr/src/app/smartcode"
git clone -b main https://github.com/aigem/smartcode.git /usr/src/app/smartcode
if [ $? -ne 0 ]; then
    echo "克隆项目失败"
    exit 1
fi

echo "检查 /usr/src/app/smartcode 目录内容："
ls -la /usr/src/app/smartcode

# 设置目录权限
echo "设置目录权限"
chown -R ${USER}:${USER} /usr/src/app/smartcode

echo "进入 /usr/src/app/smartcode 目录"
cd /usr/src/app/smartcode || {
    echo "无法进入 /usr/src/app/smartcode 目录"
    exit 1
}

echo "安装依赖"
pnpm install

echo "Remix 安装和初始化完成"
echo "当前目录内容："
ls -la

#!/bin/sh
set -e

echo "安装、配置 api-exec 开始"

# 复制/tmp的api-exec文件夹及所有文件到/usr/src/app
cp -r /tmp/api-exec /usr/src/app

# 设置目录权限
echo "设置目录权限"
chown -R ${USER}:${USER} /usr/src/app/api-exec

echo "进入 /usr/src/app/api-exec 目录"
cd /usr/src/app/api-exec || {
    echo "无法进入 /usr/src/app/api-exec 目录"
    exit 1
}

echo "安装所有依赖，包括开发依赖"
npm install

# 构建项目
echo "构建项目"
npm run build

echo "api-exec 安装和初始化完成"

#!/bin/sh
set -e

echo "安装、配置 api-exec 开始"

# 复制/tmp的api-exec文件夹及所有文件到/home/nocodb/app
cp -r /tmp/api-exec /home/nocodb/app/api-exec

# 设置目录权限
echo "设置目录权限"
chown -R ${USER}:${USER} /home/nocodb/app/api-exec
 chmod +x /home/nocodb/app/api-exec/scripts/*.sh

echo "进入 /home/nocodb/app/api-exec 目录"
cd /home/nocodb/app/api-exec || {
    echo "无法进入 /home/nocodb/app/api-exec 目录"
    exit 1
}
npm install -g pnpm
echo "安装所有依赖，包括开发依赖"
NODE_ENV=development pnpm install

# 构建 React 应用
echo "构建 api-exec React 应用..."
NODE_ENV=production pnpm build

# 清理临时文件
rm -rf /tmp/api-exec

echo "api-exec 安装和初始化完成"

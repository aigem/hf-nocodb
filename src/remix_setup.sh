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

# 设置目录权限
echo "设置目录权限"
chown -R ${USER}:${USER} /usr/src/app/smartcode

echo "进入 /usr/src/app/smartcode 目录"
cd /usr/src/app/smartcode || {
    echo "无法进入 /usr/src/app/smartcode 目录"
    exit 1
}


echo "安装依赖"
export NODE_ENV=development
pnpm install

echo "创建 .env 文件"
cat << EOF > .env
API_KEY=your_api_key_here
SESSION_SECRET=11223344556677889900
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
EOF

# 构建项目
pnpm build

# 添加这个检查
if [ -f .env ]; then
    echo ".env 文件已成功创建"
else
    echo "警告：.env 文件未能创建"
fi

echo "Remix 安装和初始化完成"

#!/bin/sh
set -e

echo "安装Cronicle开始"

# 创建必要的目录
mkdir -p ${CRONICLE_base_dir} \
         ${CRONICLE_base_dir}/logs \
         ${CRONICLE_base_dir}/data \
         ${CRONICLE_base_dir}/plugins \
         ${CRONICLE_base_dir}/conf

# 设置目录权限
chown -R ${USER}:${USER} ${CRONICLE_base_dir}

# 设置 Cronicle 配置
cat << EOF > ${CRONICLE_base_dir}/conf/config.json
{
  "base_app_url": "http://localhost:${CRONICLE_PORT}",
  "server_hostname": "localhost",
  "server_port": ${CRONICLE_PORT},
  "web_socket_use_hostnames": false,
  "base_dir": "${CRONICLE_base_dir}",
  "log_dir": "${CRONICLE_base_dir}/logs",
  "conf_dir": "${CRONICLE_base_dir}/conf",
  "data_dir": "${CRONICLE_base_dir}/data",
  "plugins_dir": "${CRONICLE_base_dir}/plugins",
  "pid_file": "${CRONICLE_base_dir}/logs/cronicled.pid",
  "secret_key": "CHANGE_THIS",
  "Storage": {
    "engine": "Filesystem",
    "Filesystem": {
      "base_dir": "data",
      "key_namespaces": 1
    }
  },  
  "WebServer": {
    "http_port": ${CRONICLE_PORT}
  }
}
EOF

# 创建 setup.json 文件
cat << EOF > ${CRONICLE_base_dir}/conf/setup.json
{
  "storage": [
    ["put", "users/admin", {
      "username": "admin",
      "password": "$2a$10$VAF.FNvz1JqhCAB5rCh9GOa965eYWH3fcgWIuQFAmsZnnVS/.ye1y",
      "full_name": "Administrator",
      "email": "admin@cronicle.com",
      "active": 1,
      "modified": 1434125333,
      "created": 1434125333,
      "salt": "salty",
      "privileges": {
        "admin": 1
      }
    }],
    ["listCreate", "global/users", {
      "page_size": 100
    }],
    ["listPush", "global/users", {
      "username": "admin"
    }],
    ["listCreate", "global/plugins", {}],
    ["listCreate", "global/categories", {}],
    ["listCreate", "global/server_groups", {}],
    ["listPush", "global/server_groups", {
      "id": "maingrp",
      "title": "Primary Group",
      "regexp": "_HOSTNAME_"
    }],
    ["listCreate", "global/servers", {}],
    ["listPush", "global/servers", {
      "hostname": "_HOSTNAME_",
      "ip": "_IP_"
    }],
    ["listCreate", "global/schedule", {}],
    ["listCreate", "global/api_keys", {}]
  ]
}
EOF

# 下载并解压 Cronicle
cd ${CRONICLE_base_dir}
curl -L https://github.com/jhuckaby/Cronicle/archive/v${CRONICLE_VER}.tar.gz | tar zxvf - --strip-components 1

# 安装依赖
npm install --omit=dev

# 构建 Cronicle
node bin/build.js dist

# 初始化存储
${CRONICLE_base_dir}/bin/control.sh setup

# 创建管理员用户（如果需要）
if ! ${CRONICLE_base_dir}/bin/storage-cli.js get users/admin > /dev/null 2>&1; then
    ${CRONICLE_base_dir}/bin/storage-cli.js admin admin admin123 admin@example.com
fi

echo "Cronicle 安装和初始化完成"

#!/bin/sh
set -e

echo "安装Cronicle开始"

# 安装 Cronicle
mkdir -p ${CRONICLE_base_dir} ${CRONICLE_base_dir}/logs ${CRONICLE_base_dir}/data ${CRONICLE_base_dir}/plugins ${CRONICLE_base_dir}/conf
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
    "list_page_size": 50,
    "concurrency": 4,
    "base_dir": "${CRONICLE_base_dir}/data"
  },
  "WebServer": {
    "http_port": ${CRONICLE_PORT}
  }
}
EOF

cd ${CRONICLE_base_dir}
curl -L https://github.com/jhuckaby/Cronicle/archive/v${CRONICLE_VER}.tar.gz | tar zxvf - --strip-components 1
npm install --omit=dev
node bin/build.js dist

# 初始化存储
${CRONICLE_base_dir}/bin/control.sh setup

# 创建管理员用户
node bin/storage-cli.js admin --create --username admin --password admin123

echo "Cronicle 安装和初始化完成"

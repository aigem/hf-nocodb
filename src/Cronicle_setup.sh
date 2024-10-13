#!/bin/sh
set -e

cronicle_version=${CRONICLE_VER}
cronicle_basedir=${CRONICLE_base_dir}

# 安装 Cronicle
mkdir -p ${cronicle_basedir}
cd ${cronicle_basedir}
curl -L https://github.com/jhuckaby/Cronicle/archive/v${cronicle_version}.tar.gz | tar zxvf - --strip-components 1
npm install
node bin/build.js dist

# 设置 Cronicle 配置
cat << EOF > ${cronicle_basedir}/conf/config.json
{
  "base_app_url": "http://localhost:7863",
  "server_hostname": "localhost",
  "server_port": 7863,
  "web_socket_use_hostnames": false,
  "base_dir": "${cronicle_basedir}",
  "log_dir": "${cronicle_basedir}/logs",
  "conf_dir": "${cronicle_basedir}/conf",
  "data_dir": "${cronicle_basedir}/data",
  "plugins_dir": "${cronicle_basedir}/plugins",
  "pid_file": "${cronicle_basedir}/logs/cronicled.pid",
  "secret_key": "CHANGE_THIS"
}
EOF

# 创建必要的目录
mkdir -p ${cronicle_basedir}/{logs,data,plugins}

# 设置权限
chown -R nocodb:nocodb ${cronicle_basedir}

# 初始化存储
cd ${cronicle_basedir}
node bin/storage-cli.js setup

# 创建管理员用户
node bin/storage-cli.js admin --create --username admin --password admin123

echo "Cronicle 安装和初始化完成"

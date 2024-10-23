#!/bin/sh
set -e

echo "安装初始化开始"

# 创建用户和目录
adduser -D -u 1000 $USER
mkdir -p /usr/app/data /run/postgresql /var/log/redis /var/log/postgresql /var/run/redis $HOME_DIR/app/traefik $HOME_DIR/static
chown -R $USER:$USER /usr/app $WORKDIR /usr /run/postgresql /var/log/redis /var/log/postgresql /var/log $HOME_DIR/app/traefik $HOME_DIR/static

# 安装软件包
apk add --no-cache postgresql postgresql-contrib redis dasel dumb-init nodejs npm wget curl tzdata vim

# 安装 http-server
npm install -g http-server pm2

# 设置密码
echo "$USER:$USER_PASSWORD" | chpasswd

# 初始化PostgreSQL
chown $USER:$USER /run/postgresql
su - $USER -c "initdb -D /usr/app/data/pgdata"
echo "host all all 0.0.0.0/0 md5" >> /usr/app/data/pgdata/pg_hba.conf
echo "listen_addresses='*'" >> /usr/app/data/pgdata/postgresql.conf

# 配置Redis
sed -i 's/# requirepass foobared/requirepass redis_password/' /etc/redis.conf
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis.conf
sed -i 's/dir .\//dir \/usr\/app\/data\//' /etc/redis.conf
sed -i 's/logfile ""/logfile "\/var\/log\/redis\/redis.log"/' /etc/redis.conf
sed -i 's/# unixsocket/unixsocket/' /etc/redis.conf
sed -i 's/# unixsocketperm 700/unixsocketperm 777/' /etc/redis.conf
echo "pidfile /var/run/redis/redis.pid" >> /etc/redis.conf
chmod 644 /etc/redis.conf
chown -R $USER:$USER /etc/redis.conf /var/log/redis /var/run/redis /usr/app/data /var/lib/redis

# 安装 Traefik
TRAEFIK_VERSION=3.1.6
wget -q https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_amd64.tar.gz
tar -xzf traefik_v${TRAEFIK_VERSION}_linux_amd64.tar.gz
mv traefik /usr/local/bin/
rm traefik_v${TRAEFIK_VERSION}_linux_amd64.tar.gz

# 复制 Traefik 配置文件
mkdir -p $HOME_DIR/app/traefik
cp /tmp/traefik.yml $HOME_DIR/app/traefik/traefik.yml
cp /tmp/dynamic_conf.yml $HOME_DIR/app/traefik/dynamic_conf.yml
chown -R $USER:$USER $HOME_DIR/app/traefik
chmod 644 $HOME_DIR/app/traefik/traefik.yml $HOME_DIR/app/traefik/dynamic_conf.yml

# 创建静态文件目录
mkdir -p $HOME_DIR/static/serve
chown -R $USER:$USER $HOME_DIR $HOME_DIR/static

echo "NocoDB 安装初始化完成"

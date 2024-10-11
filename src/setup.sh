#!/bin/sh
set -e

# 创建用户和目录
adduser -D -u 1000 nocodb
mkdir -p /usr/app/data /run/postgresql /var/log/redis /var/log/postgresql /var/run/redis
chown -R nocodb:nocodb /usr/app /usr/src/app /usr /run/postgresql /var/log/redis /var/log/postgresql /var/log

# 安装软件包
apk add --no-cache postgresql postgresql-contrib redis dasel dumb-init nodejs

# 设置密码
echo "nocodb:nocodb_password" | chpasswd

# 初始化PostgreSQL
chown nocodb:nocodb /run/postgresql
su - nocodb -c "initdb -D /usr/app/data/pgdata"
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
chown -R nocodb:nocodb /etc/redis.conf /var/log/redis /var/run/redis /usr/app/data /var/lib/redis

echo "NocoDB 安装初始化完成"

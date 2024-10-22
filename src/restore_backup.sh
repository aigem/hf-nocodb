#!/bin/sh

echo "开始恢复备份"

# 设置环境变量
HOME_DIR="/home/nocodb"
BACKUP_DIR="$HOME_DIR/backups"
BACKUP_FILE="nocodb_backup_dump.sql"
DB_NAME="nocodb"
DB_USER="nocodb"
DB_PASSWORD="nocodb_password"
DB_HOST="localhost"
DB_PORT="5432"

# 加载 S3 环境变量
if [ -f "$HOME_DIR/.s3_env" ]; then
    source "$HOME_DIR/.s3_env"
else
    echo "警告：$HOME_DIR/.s3_env 文件不存在，可能无法正确连接到 S3 存储"
fi

# 从 r2s3 下载备份文件/文件夹
echo "从 r2s3 下载备份文件"
$HOME_DIR/rclone/rclone copy r2s3:noco-db/nocodb-backups/ $BACKUP_DIR -vv

# 检查备份文件是否存在
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "错误：备份文件 $BACKUP_FILE 不存在"
    echo "跳过恢复数据库"
    exit 1
fi

# 恢复数据库(pgsql的备份)
echo "开始恢复 PostgreSQL 数据库"

# 首先，删除现有的连接并重新创建数据库
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME';"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# 然后，恢复数据
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $BACKUP_DIR/$BACKUP_FILE

# 检查恢复是否成功
if [ $? -eq 0 ]; then
    echo "数据库恢复成功"
else
    echo "错误：数据库恢复失败"
    exit 1
fi

echo "备份恢复完成"

#!/bin/bash

# 备份 PostgreSQL 数据库 到本地

# 设置数据库连接信息
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="nocodb"
DB_PASSWORD="nocodb_password"
DB_NAME="nocodb"

# 设置备份文件名和路径
BACKUP_DIR="/home/nocodb/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/nocodb_backup_dump.sql"

# 确保备份目录存在,不存在则创建
mkdir -p "$BACKUP_DIR"

# 执行数据库备份
echo "开始备份数据库..."
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "数据库备份成功: $BACKUP_FILE $TIMESTAMP"
    
    # 使用 rclone 将备份文件上传到远程存储（如果已配置）的函数
    function rclone_backup_file() {
        if command -v "$dir_rclone/rclone" &> /dev/null; then
            echo "正在使用 rclone 上传备份文件..."
            "$dir_rclone/rclone" copy "$BACKUP_FILE" remote:nocodb-backups/
            if [ $? -eq 0 ]; then
                echo "备份文件已成功上传到远程存储"
            else
                echo "备份文件上传失败，请检查 rclone 配置"
            fi
        else
            echo "rclone 未安装或未配置，跳过远程上传"
        fi
    }

    # 调用 rclone_backup_file 函数
    # rclone_backup_file
else
    echo "数据库备份失败"
    exit 1
fi

echo "备份过程完成"

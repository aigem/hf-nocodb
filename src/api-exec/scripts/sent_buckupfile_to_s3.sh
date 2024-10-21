#!/bin/bash

# 设置rclone路径
RCLONE_PATH="$HOME/rclone/rclone"
BACKUP_DIR="/home/nocodb/backups"

# 检查rclone是否存在
if [ -f "$RCLONE_PATH" ]; then
    echo "rclone 已找到"
    echo "rclone 版本: $($RCLONE_PATH --version | head -n 1)"
else
    echo "错误: rclone 未找到"
    exit 1
fi

# 检查备份文件是否存在
if [ -z "$BACKUP_FILE" ]; then
    # 如果BACKUP_FILE未定义,使用backup_sql_to_local.sh中的定义
    BACKUP_DIR="/home/nocodb/backups"
    BACKUP_FILE="$BACKUP_DIR/nocodb_backup_dump.sql"
fi

echo "BACKUP_FILE: $BACKUP_FILE"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "备份文件不存在: $BACKUP_FILE"
    exit 1
fi

# 使用rclone上传文件到S3兼容的存储服务
echo "尝试列出存储桶内容..."
$RCLONE_PATH ls r2s3:noco-db
echo "开始上传备份文件到S3兼容的存储服务..."
$RCLONE_PATH copy "$BACKUP_DIR" r2s3:noco-db/nocodb-backups/ -vv

echo "备份过程完成"

#!/bin/bash

# 设置rclone路径
RCLONE_PATH="$HOME/rclone/rclone"
echo "RCLONE_PATH: $RCLONE_PATH"

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
$RCLONE_PATH ls "r2s3:$NC_S3_BUCKET_NAME"
echo "开始上传备份文件到S3兼容的存储服务..."
$RCLONE_PATH copy "$BACKUP_FILE" "r2s3:$NC_S3_BUCKET_NAME/nocodb-backups/" -vv

# 检查上传是否成功
if [ $? -eq 0 ]; then
    echo "备份文件已成功上传到S3兼容的存储服务: r2s3:$NC_S3_BUCKET_NAME/nocodb-backups/$(basename $BACKUP_FILE)"
else
    echo "备份文件上传失败，请检查rclone配置和S3兼容存储服务的权限"
    exit 1
fi

echo "备份过程完成"

#!/bin/bash

# 加载环境变量
source /etc/profile.d/s3_env.sh

# 设置rclone路径
RCLONE_PATH="$HOME/rclone/rclone"

# 检查备份文件是否存在
if [ -z "$BACKUP_FILE" ]; then
    # 如果BACKUP_FILE未定义,使用backup_sql_to_local.sh中的定义
    BACKUP_DIR="/home/nocodb/backups"
    BACKUP_FILE="$BACKUP_DIR/nocodb_backup_dump.sql"
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "备份文件不存在: $BACKUP_FILE"
    exit 1
fi

# 配置rclone
$RCLONE_PATH config create s3 s3 \
    provider=Cloudflare \
    access_key_id=$NC_S3_ACCESS_KEY \
    secret_access_key=$NC_S3_ACCESS_SECRET \
    endpoint=$NC_S3_ENDPOINT \
    region=$NC_S3_REGION

# 使用rclone上传文件到S3兼容的存储服务
echo "开始上传备份文件到S3兼容的存储服务..."
$RCLONE_PATH copy "$BACKUP_FILE" "s3:$NC_S3_BUCKET_NAME/nocodb-backups/"

# 检查上传是否成功
if [ $? -eq 0 ]; then
    echo "备份文件已成功上传到S3兼容的存储服务: s3:$NC_S3_BUCKET_NAME/nocodb-backups/$(basename $BACKUP_FILE)"
else
    echo "备份文件上传失败，请检查rclone配置和S3兼容存储服务的权限"
    exit 1
fi

# 可选：删除本地备份文件
# rm "$BACKUP_FILE"
# echo "本地备份文件已删除"

echo "备份过程完成"

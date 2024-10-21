#!/bin/bash

# 尝试加载环境变量，如果文件不存在则输出警告
if [ -f $HOME/.s3_env ]; then
    source $HOME/.s3_env
else
    echo "警告: $HOME/.s3_env 文件不存在，将使用默认值或环境变量"
fi

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

# 检查必要的环境变量是否存在
if [ -z "$NC_S3_ACCESS_KEY" ] || [ -z "$NC_S3_ACCESS_SECRET" ] || [ -z "$NC_S3_ENDPOINT" ] || [ -z "$NC_S3_REGION" ] || [ -z "$NC_S3_BUCKET_NAME" ]; then
    echo "错误: 缺少必要的S3环境变量"
    exit 1
fi

# 创建临时rclone配置文件
TEMP_RCLONE_CONFIG=$(mktemp)

# 配置rclone
cat > "$TEMP_RCLONE_CONFIG" <<EOL
[s3]
type = s3
provider = Cloudflare
access_key_id = $NC_S3_ACCESS_KEY
secret_access_key = $NC_S3_ACCESS_SECRET
endpoint = $NC_S3_ENDPOINT
region = $NC_S3_REGION
EOL

# 使用rclone上传文件到S3兼容的存储服务
echo "开始上传备份文件到S3兼容的存储服务..."
$RCLONE_PATH --config "$TEMP_RCLONE_CONFIG" copy "$BACKUP_FILE" "s3:$NC_S3_BUCKET_NAME/nocodb-backups/"

# 检查上传是否成功
if [ $? -eq 0 ]; then
    echo "备份文件已成功上传到S3兼容的存储服务: s3:$NC_S3_BUCKET_NAME/nocodb-backups/$(basename $BACKUP_FILE)"
else
    echo "备份文件上传失败，请检查rclone配置和S3兼容存储服务的权限"
    exit 1
fi

# 删除临时配置文件
rm "$TEMP_RCLONE_CONFIG"

echo "备份过程完成"

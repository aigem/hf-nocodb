#!/bin/bash

# 输出当前用户和工作目录
echo "当前用户: $(whoami)"
echo "当前工作目录: $(pwd)"

# 尝试加载环境变量，如果文件不存在则输出警告
if [ -f $HOME/.s3_env ]; then
    echo "正在加载 $HOME/.s3_env"
    source $HOME/.s3_env
else
    echo "警告: $HOME/.s3_env 文件不存在，将使用默认值或环境变量"
fi

# 输出环境变量值（注意：不要在生产环境中显示敏感信息）
echo "NC_S3_ACCESS_KEY: ${NC_S3_ACCESS_KEY:0:5}..."
echo "NC_S3_ACCESS_SECRET: ${NC_S3_ACCESS_SECRET:0:5}..."
echo "NC_S3_ENDPOINT: $NC_S3_ENDPOINT"
echo "NC_S3_REGION: $NC_S3_REGION"
echo "NC_S3_BUCKET_NAME: $NC_S3_BUCKET_NAME"

# 设置rclone路径
RCLONE_PATH="$HOME/rclone/rclone"
echo "RCLONE_PATH: $RCLONE_PATH"

# 检查rclone是否存在
if [ -f "$RCLONE_PATH" ]; then
    echo "rclone 已找到"
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

# 详细检查每个必要的环境变量
missing_vars=()
[ -z "$NC_S3_ACCESS_KEY" ] && missing_vars+=("NC_S3_ACCESS_KEY")
[ -z "$NC_S3_ACCESS_SECRET" ] && missing_vars+=("NC_S3_ACCESS_SECRET")
[ -z "$NC_S3_ENDPOINT" ] && missing_vars+=("NC_S3_ENDPOINT")
[ -z "$NC_S3_REGION" ] && missing_vars+=("NC_S3_REGION")
[ -z "$NC_S3_BUCKET_NAME" ] && missing_vars+=("NC_S3_BUCKET_NAME")

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "错误: 以下必要的S3环境变量缺失或为空:"
    for var in "${missing_vars[@]}"; do
        echo "- $var"
    done
    exit 1
fi

# 创建临时rclone配置文件
TEMP_RCLONE_CONFIG=$(mktemp)
echo "临时rclone配置文件: $TEMP_RCLONE_CONFIG"

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

echo "rclone配置文件内容:"
cat "$TEMP_RCLONE_CONFIG"

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

#!/bin/sh
set -e

echo "开始安装 rclone..."

# 尝试加载环境变量，如果文件不存在则输出警告
if [ -f $HOME_DIR/.s3_env ]; then
    echo "正在加载 $HOME_DIR/.s3_env"
    source $HOME_DIR/.s3_env
else
    echo "警告: $HOME_DIR/.s3_env 文件不存在，将使用默认值或环境变量"
fi


# 设置下载URL和目标目录
DOWNLOAD_URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip"
TARGET_DIR="$HOME_DIR/rclone"

# 创建目标目录
mkdir -p "$TARGET_DIR" /home/nocodb/.config/rclone/
chown $USER:$USER "$TARGET_DIR" /home/nocodb/.config/rclone/

# 下载rclone
echo "下载 rclone..."
curl -L "$DOWNLOAD_URL" -o /tmp/rclone.zip

# 解压文件到临时目录
echo "解压 rclone..."
unzip -q /tmp/rclone.zip -d /tmp

# 移动rclone二进制文件到目标目录
mv /tmp/rclone-*-linux-amd64/rclone "$TARGET_DIR/"

# 设置执行权限
chmod +x "$TARGET_DIR/rclone"

# 清理临时文件
rm -rf /tmp/rclone.zip /tmp/rclone-*-linux-amd64

# 检查是否成功安装
if [ -f "$TARGET_DIR/rclone" ]; then
    echo "rclone 已成功下载并安装到 $TARGET_DIR"
    echo "rclone 版本: $($TARGET_DIR/rclone --version | head -n 1)"

    # 将rclone添加到PATH
    echo "export PATH=\$PATH:$TARGET_DIR" >> $HOME_DIR/.bashrc
    source $HOME_DIR/.bashrc

    # 添加调试输出
    echo "Debug: NC_S3_ACCESS_KEY = ${NC_S3_ACCESS_KEY}"
    echo "Debug: NC_S3_ACCESS_SECRET = ${NC_S3_ACCESS_SECRET}"
    echo "Debug: NC_S3_ENDPOINT = ${NC_S3_ENDPOINT}"
    echo "Debug: NC_S3_REGION = ${NC_S3_REGION}"

    # 创建基本配置文件
    cat > $HOME_DIR/.config/rclone/rclone.conf <<EOL
# rclone 配置文件
# S3 兼容存储配置

[r2s3]
type = s3
provider = Cloudflare
access_key_id = ${NC_S3_ACCESS_KEY}
secret_access_key = ${NC_S3_ACCESS_SECRET}
endpoint = ${NC_S3_ENDPOINT}
region = ${NC_S3_REGION}
EOL

    echo "已创建 rclone 配置文件: $HOME_DIR/.config/rclone/rclone.conf"
    cat $HOME_DIR/.config/rclone/rclone.conf
else
    echo "rclone 安装失败。请检查下载URL并重试。"
    exit 1
fi

echo "rclone 安装成功"

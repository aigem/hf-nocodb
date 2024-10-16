#!/bin/sh
set -e

echo "开始安装 rclone..."

# 设置下载URL和目标目录
DOWNLOAD_URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip"
TARGET_DIR="$HOME/rclone"

# 创建目标目录
mkdir -p "$TARGET_DIR"
chown $USER:$USER "$TARGET_DIR"

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
    echo "export PATH=\$PATH:$TARGET_DIR" >> $HOME/.bashrc
    source $HOME/.bashrc

    # 创建基本配置文件
    mkdir -p $HOME/.config/rclone
    cat > $HOME/.config/rclone/rclone.conf <<EOL
# rclone 配置文件
# 在这里添加您的远程存储配置
EOL

    echo "已创建基本配置文件: $HOME/.config/rclone/rclone.conf"
    echo "请使用 'rclone config' 命令来配置您的远程存储"
else
    echo "rclone 安装失败。请检查下载URL并重试。"
    exit 1
fi

echo "rclone 安装成功"


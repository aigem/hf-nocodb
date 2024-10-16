#!/bin/bash

log "安装 sshx..."

# 设置下载URL和目标目录
DOWNLOAD_URL="https://sshx.s3.amazonaws.com/sshx-x86_64-unknown-linux-musl.tar.gz"
TARGET_DIR="$HOME/sshx"

# 创建目标目录
mkdir -p "$TARGET_DIR"
chown $USER:$USER "$TARGET_DIR"

# 下载tar.gz文件
echo "Downloading sshx..."
curl -L "$DOWNLOAD_URL" -o /tmp/sshx.tar.gz

# 解压文件到目标目录
echo "Extracting sshx..."
tar -xzf /tmp/sshx.tar.gz -C "$TARGET_DIR"

# 清理临时文件
rm /tmp/sshx.tar.gz

# 检查是否成功解压
if [ -f "$TARGET_DIR/sshx" ]; then
    echo "sshx has been successfully downloaded and extracted to $TARGET_DIR"
    chmod +x "$TARGET_DIR/sshx"
    echo "sshx 版本: $($TARGET_DIR/sshx -V)"
else
    echo "Failed to extract sshx. Please check the download URL and try again."
    exit 1
fi

# 将sshx添加到PATH
echo "export PATH=\$PATH:$TARGET_DIR" >> $HOME/.bashrc
source $HOME/.bashrc

log "sshx 安装成功"
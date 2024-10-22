#!/bin/bash
echo "这是 SSHX 启动脚本"

# 检查 SSHX 是否已经在运行
if pgrep -f "$HOME/sshx/sshx" > /dev/null; then
    echo "SSHX 已经在运行中"
    exit 0
fi

# 启动 SSHX
$HOME/sshx/sshx -q >> /home/nocodb/static/sshx.log 2>&1 &

# 检查是否成功启动
sleep 2
if pgrep -f "$HOME/sshx/sshx" > /dev/null; then
    echo "SSHX 已成功启动"
    echo "链接信息请查看 /serve/static/sshx.log"
else
    echo "SSHX 启动失败，请检查日志文件"
fi

echo "脚本执行完毕!"

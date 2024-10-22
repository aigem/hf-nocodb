#!/bin/bash
echo "这是 SSHX 关闭脚本"

echo "sshx 版本: $($HOME/sshx/sshx -V)"

# 如何关闭sshx

# 1. 找到sshx的进程ID
sshx_pid=$(pgrep -f "$HOME/sshx/sshx")

# 2. 使用kill命令关闭进程
if [ -n "$sshx_pid" ]; then
    echo "正在关闭 SSHX 进程 (PID: $sshx_pid)"
    kill $sshx_pid
    sleep 2
    if ! pgrep -f "$HOME/sshx/sshx" > /dev/null; then
        echo "SSHX 进程已成功关闭"
    else
        echo "SSHX 进程关闭失败，尝试强制终止"
        kill -9 $sshx_pid
        sleep 1
        if ! pgrep -f "$HOME/sshx/sshx" > /dev/null; then
            echo "SSHX 进程已成功强制终止"
        else
            echo "无法关闭 SSHX 进程，请手动检查"
        fi
    fi
else
    echo "未找到正在运行的 SSHX 进程"
fi

echo "脚本执行完毕!"

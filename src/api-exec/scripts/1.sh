#!/bin/bash
echo "这是脚本1"

$HOME/sshx/sshx -q >> /home/nocodb/static/sshx.log 2>&1 &

echo "脚本执行完毕!"
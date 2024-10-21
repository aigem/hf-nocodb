#!/bin/bash
$HOME/sshx/sshx -q >> /home/nocodb/static/sshx.log 2>&1 &

echo "SSHX 已启动，链接请查看 /serve/static/sshx.log"

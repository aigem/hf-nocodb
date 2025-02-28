#!/bin/sh
set -e
# 加载数据库相关变量
if [ -f $HOME_DIR/.nocodb_env ]; then
    . $HOME_DIR/.nocodb_env
fi

echo "启动 NocoDB..."
/usr/src/appEntry/start.sh

#!/bin/bash

# 执行数据库备份
sh $(dirname "$0")/backup_sql_to_local.sh

# 如果备份成功,则发送到 S3
if [ $? -eq 0 ]; then
    sh $(dirname "$0")/sent_buckupfile_to_s3.sh
else
    echo "数据库备份失败,跳过发送到 S3 的步骤"
    exit 1
fi

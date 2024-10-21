#!/bin/bash

# 运行备份到本地的脚本
echo "开始执行本地备份..."
/bin/bash /home/nocodb/app/api-exec/scripts/backup_sql_to_local.sh

# 检查备份脚本是否成功执行
if [ $? -eq 0 ]; then
    echo "本地备份成功完成"
    
    # 运行将备份文件发送到S3的脚本
    echo "开始将备份文件上传到S3..."
    /bin/bash /home/nocodb/app/api-exec/scripts/sent_buckupfile_to_s3.sh
    
    if [ $? -eq 0 ]; then
        echo "备份文件成功上传到S3"
    else
        echo "备份文件上传到S3失败"
        exit 1
    fi
else
    echo "本地备份失败"
    exit 1
fi

echo "备份过程全部完成"

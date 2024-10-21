#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_S3_BUCKET_NAME=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_SECRET=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
echo "export LITESTREAM_S3_BUCKET=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export LITESTREAM_S3_SECRET_ACCESS_KEY=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
chmod +x $HOME_DIR/.s3_env

echo "S3 环境密钥变量设置完成"

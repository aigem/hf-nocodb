#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_S3_BUCKET_NAME=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_KEY=$(cat /run/secrets/NC_S3_ACCESS_KEY)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_SECRET=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ENDPOINT=https://6fc319456edcff6ad2c7fd9a3b55cb92.r2.cloudflarestorage.com" >> $HOME_DIR/.s3_env
echo "export NC_S3_REGION=auto" >> $HOME_DIR/.s3_env
echo "export LITESTREAM_S3_BUCKET=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export LITESTREAM_S3_SECRET_ACCESS_KEY=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
chmod +x $HOME_DIR/.s3_env

echo "S3 环境密钥变量设置完成"
echo "文件内容:"
cat $HOME_DIR/.s3_env

# 添加额外的检查
echo "检查环境变量是否正确设置:"
source $HOME_DIR/.s3_env
echo "NC_S3_BUCKET_NAME: ${NC_S3_BUCKET_NAME:0:5}..."
echo "NC_S3_ACCESS_KEY: ${NC_S3_ACCESS_KEY:0:5}..."
echo "NC_S3_ACCESS_SECRET: ${NC_S3_ACCESS_SECRET:0:5}..."
echo "NC_S3_ENDPOINT: $NC_S3_ENDPOINT"
echo "NC_S3_REGION: $NC_S3_REGION"

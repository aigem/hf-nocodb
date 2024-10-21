#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_S3_BUCKET_NAME=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_KEY=8cebf2d01e174f6d7194ce3cb4640899" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_SECRET=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ENDPOINT=https://6fc319456edcff6ad2c7fd9a3b55cb92.r2.cloudflarestorage.com" >> $HOME_DIR/.s3_env
echo "export NC_S3_REGION=auto" >> $HOME_DIR/.s3_env
chmod +x $HOME_DIR/.s3_env
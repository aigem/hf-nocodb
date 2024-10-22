#!/bin/sh
set -e

# 将环境变量写入到 nocodb 用户的主目录
echo "export NC_S3_BUCKET_NAME=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_KEY=$(cat /run/secrets/NC_S3_ACCESS_KEY)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ACCESS_SECRET=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> $HOME_DIR/.s3_env
echo "export NC_S3_ENDPOINT=$(cat /run/secrets/NC_S3_ENDPOINT)" >> $HOME_DIR/.s3_env
echo "export NC_S3_REGION=$(cat /run/secrets/NC_S3_REGION)" >> $HOME_DIR/.s3_env

chmod 644 $HOME_DIR/.s3_env
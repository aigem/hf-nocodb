#!/bin/sh
set -e

echo "export NC_S3_BUCKET_NAME=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> /etc/profile.d/s3_env.sh
echo "export NC_S3_ACCESS_SECRET=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> /etc/profile.d/s3_env.sh
echo "export LITESTREAM_S3_BUCKET=$(cat /run/secrets/NC_S3_BUCKET_NAME)" >> /etc/profile.d/s3_env.sh
echo "export LITESTREAM_S3_SECRET_ACCESS_KEY=$(cat /run/secrets/NC_S3_ACCESS_SECRET)" >> /etc/profile.d/s3_env.sh
chmod +x /etc/profile.d/s3_env.sh

echo "S3 环境密钥变量设置完成"

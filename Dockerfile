FROM nocodb/nocodb:latest

ARG NC_S3_REGION
ARG NC_S3_ENDPOINT
ARG NC_S3_ACCESS_KEY

RUN apk add --no-cache git \
    && git clone https://github.com/aigem/hf-nocodb.git /usr/src


COPY setup.sh s3_setup.sh /tmp/
COPY docker/startup.sh /usr/src/appEntry/startup.sh

RUN --mount=type=secret,id=NC_S3_BUCKET_NAME,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_ACCESS_SECRET,mode=0444,required=true \
    /tmp/setup.sh && \
    chmod +x /usr/src/appEntry/startup.sh && \
    /tmp/s3_setup.sh && \
    rm /tmp/setup.sh /tmp/s3_setup.sh

USER nocodb

WORKDIR /usr/src/app

# 设置环境变量
ENV LITESTREAM_S3_SKIP_VERIFY=false \
    LITESTREAM_RETENTION=1440h \
    LITESTREAM_RETENTION_CHECK_INTERVAL=72h \
    LITESTREAM_SNAPSHOT_INTERVAL=24h \
    LITESTREAM_SYNC_INTERVAL=60s \
    NC_DOCKER=0.6 \
    NC_TOOL_DIR=/usr/app/data/ \
    NODE_ENV=production \
    PORT=7860 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4" \
    NC_S3_REGION=${NC_S3_REGION} \
    NC_S3_ENDPOINT=${NC_S3_ENDPOINT} \
    NC_S3_ACCESS_KEY=${NC_S3_ACCESS_KEY} \
    LITESTREAM_S3_REGION=${NC_S3_REGION} \
    LITESTREAM_S3_ENDPOINT=${NC_S3_ENDPOINT} \
    LITESTREAM_S3_ACCESS_KEY_ID=${NC_S3_ACCESS_KEY}

ENV $(source /etc/profile.d/s3_env.sh && env | grep '^S3_' | xargs)

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]
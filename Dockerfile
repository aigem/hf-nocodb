FROM nocodb/nocodb:latest

ARG CACHEBUST=22

# 设置环境变量
ENV WORKDIR=/usr/src/app \
    USER=nocodb \
    HOME_DIR=/home/nocodb \
    NC_DB="pg://localhost:5432?u=nocodb&p=nocodb_password&d=nocodb" \
    NC_AUTH_JWT_SECRET=nocodb_jwt_secret \
    NC_TOOL_DIR=/usr/app/data/ \
    PORT=7861 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4" \
    RESTORE_BACKUP=true

RUN --mount=type=secret,id=NC_S3_BUCKET_NAME,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_ACCESS_SECRET,mode=0444,required=true \
    apk add --no-cache git curl nodejs npm \
    && git clone -b pro https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    # 复制src下的所有文件夹及文件到/tmp/
    && cp -r /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && cp /tmp/restore_backup.sh /usr/src/appEntry/restore_backup.sh \
    && chmod +x /usr/src/appEntry/*.sh
    # 安装 setup.sh
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 安装 api-exec
    && chmod +x /tmp/apiexec_setup.sh && /tmp/apiexec_setup.sh \
    # 安装 sshx
    && chmod +x /tmp/sshx_setup.sh && /tmp/sshx_setup.sh \
    # s3设置
    && chmod +x /tmp/s3_setup.sh && /tmp/s3_setup.sh \
    # rclone安装与设置
    && chmod +x /tmp/rclone_setup.sh && /tmp/rclone_setup.sh

USER ${USER}

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]

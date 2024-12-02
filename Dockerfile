FROM nocodb/nocodb:latest

ARG CACHEBUST=10

# 设置环境变量
ENV WORKDIR=/usr/src/app \
    USER=nocodb \
    HOME_DIR=/home/$USER \
    NC_AUTH_JWT_SECRET=nocodb_jwt_secret \
    NC_TOOL_DIR=/usr/app/data/ \
    PORT=7861 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4" \
    RESTORE_BACKUP=false \
    HTTP_SERVER_ROOT=/home/nocodb/static

RUN --mount=type=secret,id=NC_S3_BUCKET_NAME,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_ACCESS_SECRET,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_ENDPOINT,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_REGION,mode=0444,required=true \
    --mount=type=secret,id=NC_S3_ACCESS_KEY,mode=0444,required=true \
    --mount=type=secret,id=DB_Host,mode=0444,required=true \
    --mount=type=secret,id=DB_Port,mode=0444,required=true \
    --mount=type=secret,id=DB_User,mode=0444,required=true \
    --mount=type=secret,id=DB_Password,mode=0444,required=true \
    --mount=type=secret,id=DB_Database,mode=0444,required=true \
    apk add --no-cache git curl nodejs npm \
    && git clone -b pro https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    # 复制src下的所有文件夹及文件到/tmp/
    && cp -r /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && cp /tmp/restore_backup.sh /usr/src/appEntry/restore_backup.sh \
    && chmod +x /usr/src/appEntry/*.sh \
    # 检查是否存在各sh文件
    && ls -l /tmp/ && ls -l /usr/src/appEntry/ \
    # 安装 setup.sh
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 安装 sshx
    && chmod +x /tmp/sshx_setup.sh && /tmp/sshx_setup.sh \
    # s3设置
    && chmod +x /tmp/s3_setup.sh && /tmp/s3_setup.sh \
    # nocodb设置
    && chmod +x /tmp/nocodb_setup.sh && /tmp/nocodb_setup.sh
    # rclone安装与设置
    # && chmod +x /tmp/rclone_setup.sh && /tmp/rclone_setup.sh

USER ${USER}

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]

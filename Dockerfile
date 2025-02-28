FROM nocodb/nocodb:latest

ARG CACHEBUST=1

# 设置环境变量
ENV WORKDIR=/usr/src/app \
    USER=nocodb \
    HOME_DIR=/home/nocodb \
    PORT=7860 \
    RESTORE_BACKUP=false

RUN --mount=type=secret,id=DB_Host,mode=0444,required=true \
    --mount=type=secret,id=DB_Port,mode=0444,required=true \
    --mount=type=secret,id=DB_User,mode=0444,required=true \
    --mount=type=secret,id=DB_Password,mode=0444,required=true \
    --mount=type=secret,id=DB_Database,mode=0444,required=true \
    apt-get update && apt-get install -y git curl \
    && git clone -b new https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    # 复制src下的所有文件夹及文件到/tmp/
    && cp -r /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && chmod +x /usr/src/appEntry/*.sh \
    # 检查是否存在各sh文件
    && ls -l /tmp/ && ls -l /usr/src/appEntry/ \
    # 安装 setup.sh
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 环境变量设置
    && chmod +x /tmp/env_setup.sh && /tmp/env_setup.sh

USER ${USER}

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]
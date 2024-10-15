FROM nocodb/nocodb:latest

ARG CACHEBUST=22

# 设置环境变量
ENV WORKDIR=/usr/src/app \
    USER=nocodb \
    NC_DB="pg://localhost:5432?u=nocodb&p=nocodb_password&d=nocodb" \
    NC_AUTH_JWT_SECRET=nocodb_jwt_secret \
    NC_TOOL_DIR=/usr/app/data/ \
    PORT=7861 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4"

RUN apk add --no-cache git curl nodejs npm

RUN git clone -b pro https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    # 复制src下的所有文件夹及文件到/tmp/
    && cp -r /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && chmod +x /usr/src/appEntry/startup.sh \
    # 安装 setup.sh
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 安装 smartcode
    && chmod +x /tmp/remix_setup.sh && /tmp/remix_setup.sh \
    # 安装 api-exec
    && chmod +x /tmp/apiexec_setup.sh && /tmp/apiexec_setup.sh \
    && rm -rf /tmp/hf-nocodb /tmp/*.sh

USER ${USER}

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]

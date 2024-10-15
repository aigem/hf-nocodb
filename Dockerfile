FROM nocodb/nocodb:latest

# 设置环境变量
ENV WORKDIR=/usr/src/app \
    USER=nocodb \
    NC_DB="pg://localhost:5432?u=nocodb&p=nocodb_password&d=nocodb" \
    NC_AUTH_JWT_SECRET=nocodb_jwt_secret \
    NC_TOOL_DIR=/usr/app/data/ \
    NODE_ENV=production \
    PORT=7861 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4"
    # CRONICLE_PORT=7863 \
    # CRONICLE_base_dir=/opt/cronicle \
    # CRONICLE_VER=0.9.60

RUN apk add --no-cache git curl nodejs npm
    
ARG CACHEBUST=1

RUN git clone -b pro https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    && cp /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && chmod +x /usr/src/appEntry/startup.sh \
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 安装 cronicle
    # && chmod +x /tmp/Cronicle_setup.sh && /tmp/Cronicle_setup.sh \
    # 安装 smartcode
    && chmod +x /tmp/remix_setup.sh && /tmp/remix_setup.sh \
    && rm -rf /tmp/hf-nocodb /tmp/*.sh

USER ${USER}

WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]

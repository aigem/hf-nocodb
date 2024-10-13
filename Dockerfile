FROM nocodb/nocodb:latest

RUN apk add --no-cache git curl nodejs npm \
    && git clone -b dev https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    && cp /tmp/hf-nocodb/src/* /tmp/ \
    && cp /tmp/startup.sh /usr/src/appEntry/startup.sh \
    && chmod +x /usr/src/appEntry/startup.sh /tmp/setup.sh /tmp/Cronicle_setup.sh \
    && /tmp/setup.sh \
    && /tmp/Cronicle_setup.sh \
    && rm -rf /tmp/hf-nocodb /tmp/setup.sh /tmp/Cronicle_setup.sh

USER nocodb

WORKDIR /usr/src/app

# 设置环境变量
ENV NC_DB="pg://localhost:5432?u=nocodb&p=nocodb_password&d=nocodb" \
    NC_AUTH_JWT_SECRET=nocodb_jwt_secret \
    NC_TOOL_DIR=/usr/app/data/ \
    NODE_ENV=production \
    PORT=7861 \
    NC_ALLOW_LOCAL_HOOKS=true \
    NC_REDIS_URL="redis://:redis_password@localhost:6379/4"
    
ARG CRONICLE_PORT=7863 \
    CRONICLE_base_dir=/opt/cronicle \
    CRONICLE_VER=0.9.60

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/appEntry/startup.sh"]
FROM nocodb/nocodb:latest

# 添加镜像元信息
LABEL maintainer="ai来事"
LABEL description="NocoDB是一个开源的Airtable替代方案，可以将任何MySQL、PostgreSQL、SQL Server、SQLite和MariaDB转换为智能电子表格。免费、开源、无限制。"
LABEL video.tutorial="https://www.bilibili.com/video/BV1SP2mYBEjC/"
LABEL github.repository="https://github.com/aigem/hf-nocodb"

# 构建参数（默认值可替换，替换为其它值来重新进行部署）
ARG CACHEBUST=12

# 切换用户并配置权限
USER root

ARG DB_POSTGRESDB_SCHEMA=$DB_POSTGRESDB_SCHEMA
ARG DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST
ARG DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE
ARG DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT
ARG DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER
ARG DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD

# 下载脚本文件
RUN curl -o /tmp/setup.sh https://raw.githubusercontent.com/aigem/hf-nocodb/new/setup.sh && \
    curl -o /tmp/start.sh https://raw.githubusercontent.com/aigem/hf-nocodb/new/start.sh && \
    mv /tmp/setup.sh /usr/src/appEntry/ && \
    mv /tmp/start.sh /usr/src/appEntry/ && \
    chmod +x /usr/src/appEntry/setup.sh /usr/src/appEntry/start.sh

# 执行设置脚本
RUN --mount=type=secret,id=DB_POSTGRESDB_USER,mode=0444,required=true \
    --mount=type=secret,id=DB_POSTGRESDB_PASSWORD,mode=0444,required=true \
    /usr/src/appEntry/setup.sh

# 切换回 node 用户
USER node

# 运行时执行启动脚本
CMD ["/usr/src/appEntry/start.sh"]
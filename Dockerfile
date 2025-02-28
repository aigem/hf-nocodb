FROM nikolaik/python-nodejs:python3.12-nodejs22

# 添加 CACHEBUST 参数
ARG CACHEBUST=1

ENV USER=pn \
    HOME_DIR=/home/pn \
    PORT=7860

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    libpq-dev \
    neofetch \
    git \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${HOMEDIR}

RUN --mount=type=secret,id=DB_Host,mode=0444,required=true \
    --mount=type=secret,id=DB_Port,mode=0444,required=true \
    --mount=type=secret,id=DB_User,mode=0444,required=true \
    --mount=type=secret,id=DB_Password,mode=0444,required=true \
    --mount=type=secret,id=DB_Database,mode=0444,required=true \
    apt-get update && apt-get install -y git curl \
    && git clone -b new https://github.com/aigem/hf-nocodb.git /tmp/hf-nocodb \
    # 复制src下的所有文件夹及文件到/tmp/
    && cp -r /tmp/hf-nocodb/src/* /tmp/ && cp /tmp/startup.sh ${HOME_DIR}/startup.sh \
    && chmod +x ${HOME_DIR}/*.sh \
    # 检查是否存在各sh文件
    && ls -l /tmp/ && ls -l ${HOME_DIR}/ \
    # 安装 setup.sh
    && chmod +x /tmp/setup.sh && /tmp/setup.sh \
    # 环境变量设置
    && chmod +x /tmp/env_setup.sh && /tmp/env_setup.sh

USER ${USER}

WORKDIR ${WORKDIR}

CMD ["/home/pn/startup.sh"]

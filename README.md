---
title: NocoDB
emoji: 📚
colorFrom: gray
colorTo: red
sdk: docker
pinned: false
---

# hf-nocodb

### 在 HuggingFace 上部署 NocoDB，开源版本的 AirTable。支持 S3 数据持久化，部署简单，部署后数据仍然保留。我们使用 Cloudflare R2 作为 S3 对象存储。

## 一键部署【推荐】

在本项目的 [Spaces](https://huggingface.co/spaces/fuliai/nocodb) 中，点击右上角 [复制Spaces](https://huggingface.co/spaces/fuliai/nocodb) 按钮即可完成部署。

### [一键复制本项目地址](https://huggingface.co/spaces/fuliai/nocodb)

### [视频教程](https://www.bilibili.com/video/BV1SP2mYBEjC/)

## 配置说明

- **环境变量**：请在部署前设置必要的环境变量，如数据库连接信息、S3 存储配置等。
- **Secrets 管理**：通过 Docker secrets 管理敏感信息，确保安全性。

## 使用指南

1. 克隆仓库
    ```bash
    git clone https://github.com/aigem/hf-nocodb.git
    cd hf-nocodb
    ```

2. 配置环境变量
    ```bash
    cp .env.example .env
    # 编辑 .env 文件，设置必要的配置
    ```

3. 构建并运行 Docker 容器
    ```bash
    docker build -t hf-nocodb .
    docker run -d -p 7861:7861 --name nocodb hf-nocodb
    ```

## 常见问题

- **数据库连接失败**：请检查数据库容器是否已正确启动，并确认连接信息无误。
- **S3 上传失败**：请确认 S3 配置参数是否正确，并检查网络连接。

## 贡献指南

欢迎提交 PR 和 Issues，欢迎讨论和建议！

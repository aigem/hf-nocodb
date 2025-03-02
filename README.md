---
title: NocoDB
emoji: 📚
colorFrom: gray
colorTo: red
sdk: docker
pinned: false
app_port : 8080
---

# hf-nocodb

在 HuggingFace 上部署 NocoDB，AirTable的开源平替。支持数据持久化，部署后数据仍然保留。
### [视频教程](https://www.bilibili.com/video/BV1SP2mYBEjC/)

## 一键部署

1. 打开本项目的 [Spaces](https://huggingface.co/spaces/fuliai/nocodb)，点击右上角【复制Spaces】按钮
2. 在创建页面中填入你的账号名及空间名
3. 填入Supabase数据库配置信息即可完成部署
   - 访问 [Supabase官网](https://supabase.com) 创建数据库
   - 在项目设置中获取数据库连接信息

### 环境变量配置

部署时需要设置以下环境变量：

- `DB_POSTGRESDB_HOST`: 数据库主机地址
- `DB_POSTGRESDB_PORT`: 数据库端口
- `DB_POSTGRESDB_USER`: 数据库用户名
- `DB_POSTGRESDB_PASSWORD`: 数据库密码
- `DB_POSTGRESDB_DATABASE`: 数据库名称

## 常见问题

- **数据库连接失败**：请检查Supabase数据库连接信息是否正确填写
- **权限问题**：确保数据库用户具有足够的权限

## 相关链接

- [视频教程](https://www.bilibili.com/video/BV1SP2mYBEjC/)
- github项目地址：
- [一键复制地址](https://huggingface.co/spaces/fuliai/nocodb)
- nocodb官网：https://nocodb.com/

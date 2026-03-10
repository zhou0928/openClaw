# OpenClaw Docker 部署指南

本文档介绍如何使用 Docker/OrbStack 部署 OpenClaw，实现开机自启动和持续运行。

## 🚀 快速开始

### 一键部署

```bash
./scripts/docker-deploy.sh
```

### 手动部署

```bash
# 1. 构建镜像
docker build -t openclaw:local .

# 2. 启动容器
docker-compose up -d

# 3. 查看状态
docker-compose ps
```

## 🔧 常用命令

```bash
# 查看日志
docker-compose logs -f

# 重启容器
docker-compose restart

# 更新部署
./scripts/docker-update.sh

# 进入 CLI
docker-compose exec openclaw-cli bash
```

## 📋 配置说明

端口: http://localhost:18789/
Token: 5f6a2372c8714083555881cc937a5a99e054a98068f5e1b2256ee99a2a6e4470

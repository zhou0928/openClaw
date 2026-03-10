# OpenClaw Docker 快速参考

## 🚀 一键命令

### 首次部署

```bash
cd /Users/xiaozhou/Desktop/openclaws
chmod +x scripts/docker-*.sh
./scripts/docker-deploy.sh
```

### 日常启动

```bash
./scripts/docker-start.sh
```

### 停止服务

```bash
./scripts/docker-stop.sh
```

### 更新部署

```bash
./scripts/docker-update.sh
```

## 📋 访问信息

- **网页控制面板**: http://localhost:9999/
- **Gateway Token**: `my-fixed-openclaw-token-please-change-this-in-production`

## 🔧 常用命令

### 查看日志

```bash
# 所有日志
docker compose --env-file .env.docker logs -f

# 网关日志
docker compose --env-file .env.docker logs -f openclaw-gateway

# CLI 日志
docker compose --env-file .env.docker logs -f openclaw-cli
```

### 查看状态

```bash
# 容器状态
docker compose --env-file .env.docker ps

# 网关状态
docker compose --env-file .env.docker run --rm openclaw-cli gateway status

# 配置信息
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote
```

### 进入容器

```bash
# 进入 CLI 容器
docker compose --env-file .env.docker exec openclaw-cli bash

# 在容器中执行命令
docker compose --env-file .env.docker exec openclaw-cli openclaw channels list
docker compose --env-file .env.docker exec openclaw-cli openclaw models status
```

### 容器管理

```bash
# 重启容器
docker compose --env-file .env.docker restart

# 停止容器
docker compose --env-file .env.docker down

# 完全清理（包括数据卷）
docker compose --env-file .env.docker down -v
```

## ✅ 验证自动连接

```bash
# 1. 检查容器状态
docker compose --env-file .env.docker ps

# 2. 检查网关日志（应该看到 "gateway listening"）
docker compose --env-file .env.docker logs openclaw-gateway | grep listening

# 3. 检查自动连接配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote

# 4. 测试网关状态
docker compose --env-file .env.docker run --rm openclaw-cli gateway status
```

## 🐛 故障排除

### 重新配置自动连接

```bash
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:9999"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.token "my-fixed-openclaw-token-please-change-this-in-production"
docker compose --env-file .env.docker restart
```

### 端口被占用

```bash
# 查看占用进程
lsof -i :9999

# 终止占用进程
lsof -ti :9999 | xargs kill -9
```

### 容器无法启动

```bash
# 查看详细日志
docker compose --env-file .env.docker logs openclaw-gateway

# 重新部署
./scripts/docker-deploy.sh
```

## 📝 配置文件

### `.env.docker`

```bash
OPENCLAW_GATEWAY_PORT=9999
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_TOKEN=my-fixed-openclaw-token-please-change-this-in-production
OPENCLAW_CONFIG_DIR=~/.openclaw
OPENCLAW_WORKSPACE_DIR=~/.openclaw/workspace
OPENCLAW_IMAGE=openclaw:local
OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=true
```

### `~/.openclaw/openclaw.json`

```json
{
  "gateway": {
    "remote": {
      "url": "ws://127.0.0.1:9999",
      "token": "my-fixed-openclaw-token-please-change-this-in-production",
      "enabled": true
    }
  }
}
```

## 🎯 工作流程

```
第一次:
docker-deploy.sh → 构建镜像 + 配置自动连接 → 启动服务 → 直接使用

日常:
docker-start.sh → 启动服务 → 自动连接 → 直接使用

更新:
docker-update.sh → 重新构建 + 重启服务 → 自动连接 → 直接使用
```

## 💡 提示

- ✅ Token 已固定，无需每次输入
- ✅ CLI 自动连接到网关，无需手动连接
- ✅ 配置保存在 `~/.openclaw`，容器重启不会丢失
- ✅ 容器设置自动重启，崩溃后自动恢复

## 📚 相关文档

- [完整部署指南](../DOCKER_DEPLOY.md)
- [自动连接修复说明](../DOCKER_AUTOCONNECT_FIX.md)
- [脚本使用指南](README.md)
- [项目主文档](../README.md)

# OpenClaw Docker 配置状态总结

## ✅ 当前配置状态

### 网关配置 (`~/.openclaw/openclaw.json`)

```json
{
  "gateway": {
    "mode": "local",
    "remote": {
      "url": "ws://127.0.0.1:9999",
      "token": "my-fixed-openclaw-token-please-change-this-in-production"
    },
    "auth": {
      "token": "my-fixed-openclaw-token-please-change-this-in-production",
      "mode": "token"
    }
  }
}
```

### 环境配置 (`.env.docker`)

```bash
OPENCLAW_GATEWAY_PORT=9999
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_TOKEN=my-fixed-openclaw-token-please-change-this-in-production
OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=true
OPENCLAW_CONFIG_DIR=~/.openclaw
OPENCLAW_WORKSPACE_DIR=~/.openclaw/workspace
```

### 容器状态

```
✅ openclaws-openclaw-gateway-1: 运行中，健康
   - 监听地址: ws://0.0.0.0:9999
   - 网页控制面板: http://localhost:9999/
```

## 🚀 使用方法

### 1. 启动服务

```bash
# 快速启动（如果容器已停止）
./scripts/docker-start.sh

# 或完整部署（第一次使用）
./scripts/docker-deploy.sh
```

### 2. 访问网关

**通过浏览器访问：**

- 打开浏览器访问: http://localhost:9999/
- 输入 Token: `my-fixed-openclaw-token-please-change-this-in-production`
- 浏览器会保存 Token，之后无需再次输入

**通过 CLI 访问：**

```bash
# 进入 CLI 容器
docker compose --env-file .env.docker exec openclaw-cli bash

# 运行 OpenClaw 命令
openclaw gateway status
openclaw channels status
```

### 3. 常用命令

```bash
# 查看日志
docker compose --env-file .env.docker logs -f

# 查看网关日志
docker compose --env-file .env.docker logs -f openclaw-gateway

# 停止服务
./scripts/docker-stop.sh

# 重启服务
./scripts/docker-stop.sh && ./scripts/docker-start.sh

# 更新部署
./scripts/docker-update.sh

# 进入 CLI
docker compose --env-file .env.docker exec openclaw-cli bash
```

## 📋 配置说明

### 双重认证配置

OpenClaw 使用双重认证系统来实现自动化：

1. **CLI 端配置** (`gateway.remote.*`)
   - `gateway.remote.url`: 告诉 CLI 连接到哪个网关
   - `gateway.remote.token`: 告诉 CLI 使用什么 token

2. **网关端配置** (`gateway.auth.*`)
   - `gateway.auth.token`: 告诉网关接受什么 token
   - `gateway.auth.mode`: 认证模式（设置为 "token"）

**关键点：两边配置必须一致！**

### 网关模式说明

- `gateway.mode: "local"` - 网关容器本身使用此模式，表示网关直接运行，不连接到远程网关
- `gateway.remote.url` - 仅在 CLI 需要连接远程网关时使用（当前配置为 ws://127.0.0.1:9999）

### 安全配置

- `OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=true`: 允许使用 ws:// 连接到本地回环地址（开发环境）
- `gateway.controlUi.allowInsecureAuth=true`: 允许不安全的认证（开发环境）
- `gateway.controlUi.dangerouslyDisableDeviceAuth=true`: 禁用设备认证（开发环境）

⚠️ **生产环境请修改这些安全设置！**

## 🔧 故障排查

### 问题：需要输入 token

**检查配置：**

```bash
# 检查网关认证配置
cat ~/.openclaw/openclaw.json | jq '.gateway.auth'

# 检查 CLI 配置
cat ~/.openclaw/openclaw.json | jq '.gateway.remote'
```

**预期输出：**

```json
{
  "auth": {
    "mode": "token",
    "token": "my-fixed-openclaw-token-please-change-this-in-production"
  },
  "remote": {
    "url": "ws://127.0.0.1:9999",
    "token": "my-fixed-openclaw-token-please-change-this-in-production"
  }
}
```

### 问题：网关无法启动

**检查日志：**

```bash
docker logs openclaws-openclaw-gateway-1 --tail 50
```

**常见错误：**

- `Gateway start blocked: set gateway.mode=local` - 确保配置文件中 `gateway.mode=local`
- 端口被占用 - 检查 9999 端口是否被其他服务占用

### 问题：浏览器无法访问

**检查：**

1. 网关是否正在运行: `docker ps`
2. 端口是否正确: `lsof -i :9999`
3. 浏览器控制台是否有错误

## 🎯 完成标志

当满足以下条件时，配置成功：

- ✅ 网关容器正常运行（`docker ps` 显示 `healthy`）
- ✅ 网关监听在 `ws://0.0.0.0:9999`
- ✅ 浏览器访问 `http://localhost:9999/` 可以打开
- ✅ 输入一次 token 后，浏览器保存，无需再次输入
- ✅ 配置文件包含正确的 `gateway.auth` 和 `gateway.remote` 设置

## 📚 相关文档

- [Docker 部署指南](DOCKER_DEPLOY.md)
- [Token 修复指南](TOKEN_FIX_GUIDE.md)
- [自动连接修复说明](DOCKER_AUTOCONNECT_FIX.md)
- [改进总结](DOCKER_IMPROVEMENTS_SUMMARY.md)
- [修复总结](DOCKER_FIX_SUMMARY.md)
- [脚本使用指南](scripts/README.md)
- [快速参考](scripts/QUICK_REFERENCE.md)

## 🎉 总结

**当前配置已完全满足您的需求：**

1. ✅ 固定 Token，无需每次生成新的
2. ✅ 网关自动启动，无需手动连接
3. ✅ 浏览器访问时只需输入一次 token，之后自动保存
4. ✅ 所有脚本已更新，使用正确的配置

**下次启动：**

```bash
./scripts/docker-start.sh
# 然后直接访问 http://localhost:9999/
```

**享受自动化的 OpenClaw 体验！** 🦞

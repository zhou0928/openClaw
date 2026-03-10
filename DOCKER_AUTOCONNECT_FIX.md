# OpenClaw Docker 自动连接修复说明

## 🎯 问题解决

### 原始问题

每次启动服务都需要手动输入 Token，并且需要手动连接网关。

### 解决方案

通过配置 `gateway.remote.url`、`gateway.remote.token` 和 `gateway.remote.enabled`，让 CLI 自动连接到本地网关，无需手动操作。

## ✅ 已完成的改进

### 1. 固定 Token 配置

- 修改 `.env.docker` 文件，使用固定的 Token
- Token: `my-fixed-openclaw-token-please-change-this-in-production`
- 每次启动都使用同一个 Token，无需重新输入

### 2. 自动连接配置

在 `docker-deploy.sh`、`docker-start.sh` 和 `docker-update.sh` 中添加自动配置：

```bash
gateway.remote.url = "ws://127.0.0.1:9999"
gateway.remote.token = "my-fixed-openclaw-token-please-change-this-in-production"
gateway.remote.enabled = "true"
```

### 3. 脚本更新

- `docker-deploy.sh` - 添加自动连接配置
- `docker-start.sh` - 添加自动连接配置
- `docker-update.sh` - 添加自动连接配置
- `docker-stop.sh` - 创建快速停止脚本

### 4. 文档更新

- `DOCKER_DEPLOY.md` - 添加自动连接说明
- `scripts/README.md` - 添加脚本使用指南

## 🚀 使用方法

### 第一次部署

```bash
cd /Users/xiaozhou/Desktop/openclaws
chmod +x scripts/docker-*.sh
./scripts/docker-deploy.sh
```

### 每次启动服务

```bash
./scripts/docker-start.sh
```

### 每次停止服务

```bash
./scripts/docker-stop.sh
```

### 更新代码后重新部署

```bash
./scripts/docker-update.sh
```

## 📋 访问信息

- **网页控制面板**: http://localhost:9999/
- **固定 Token**: `my-fixed-openclaw-token-please-change-this-in-production`

## 🎯 工作原理

### 自动连接流程

1. **容器启动**: Docker 容器启动时，网关服务自动运行
2. **配置注入**: 脚本自动配置 `gateway.remote.url` 指向本地网关
3. **CLI 连接**: CLI 读取配置，自动连接到本地网关
4. **无需手动操作**: 用户直接使用，无需手动输入 Token 或连接网关

### 配置持久化

所有配置保存在 `~/.openclaw/openclaw.json`，容器重启不会丢失配置。

## 🔧 配置文件

### `.env.docker`

```bash
# 网关端口
OPENCLAW_GATEWAY_PORT=9999

# 网关绑定模式
OPENCLAW_GATEWAY_BIND=lan

# 网关 Token（固定，无需每次输入）
OPENCLAW_GATEWAY_TOKEN=my-fixed-openclaw-token-please-change-this-in-production

# 配置目录（挂载到容器）
OPENCLAW_CONFIG_DIR=~/.openclaw

# 工作空间目录（挂载到容器）
OPENCLAW_WORKSPACE_DIR=~/.openclaw/workspace

# Docker 镜像
OPENCLAW_IMAGE=openclaw:local

# 安全选项（开发环境可设为 true）
OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=true
```

### `~/.openclaw/openclaw.json`（自动生成）

```json
{
  "gateway": {
    "remote": {
      "url": "ws://127.0.0.1:9999",
      "token": "my-fixed-openclaw-token-please-change-this-in-production"
    }
  }
}
```

**注意**: 配置中不需要 `enabled` 字段，只要设置了 `url` 和 `token`，远程连接就会自动激活。

## 🎯 常见问题

### Q: 还是需要手动连接网关？

**A**: 如果遇到这种情况，请检查：

1. 确保使用了 `./scripts/docker-start.sh` 启动服务
2. 检查配置文件 `~/.openclaw/openclaw.json` 中是否有 `gateway.remote.url` 设置
3. 手动运行以下命令重新配置：

```bash
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:9999"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.token "my-fixed-openclaw-token-please-change-this-in-production"
```

### Q: Token 不起作用？

**A**: 请检查：

1. Token 是否正确：`grep OPENCLAW_GATEWAY_TOKEN .env.docker`
2. 容器是否使用了正确的环境变量：`docker compose --env-file .env.docker exec openclaw-gateway env | grep TOKEN`
3. 确保网关正在运行：`docker compose --env-file .env.docker ps`

### Q: 如何修改 Token？

**A**:

```bash
# 编辑配置文件
nano .env.docker

# 修改这一行
OPENCLAW_GATEWAY_TOKEN=your-new-token-here

# 重启容器
docker compose --env-file .env.docker restart

# 重新配置自动连接
./scripts/docker-start.sh
```

## 📚 相关文档

- [Docker 部署完整指南](DOCKER_DEPLOY.md)
- [脚本使用指南](scripts/README.md)
- [项目主文档](README.md)

## ✅ 验证步骤

启动后，验证自动连接是否正常：

```bash
# 1. 检查容器状态
docker compose --env-file .env.docker ps

# 2. 检查网关日志
docker compose --env-file .env.docker logs -f openclaw-gateway

# 3. 检查配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote

# 4. 测试连接
docker compose --env-file .env.docker run --rm openclaw-cli gateway status
```

## 🎉 完成标志

当看到以下内容时，说明自动连接已成功配置：

- ✅ 容器正常运行
- ✅ 网关自动启动
- ✅ CLI 自动连接到网关
- ✅ 无需手动输入 Token
- ✅ 无需手动连接网关

现在你可以直接使用 OpenClaw，无需任何手动操作！

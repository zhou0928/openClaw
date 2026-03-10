# OpenClaw Docker Token 自动化 - 完整解决方案

## 🎯 问题根源

即使配置了 `gateway.remote.token`，CLI 仍然要求输入 token。这是因为：

1. `gateway.remote.token` - 告诉 CLI 使用什么 token 连接到网关
2. `gateway.auth.token` - 告诉网关接受什么 token 进行认证

**两者都需要配置才能实现完全自动化！**

## ✅ 完整配置方案

### 需要配置的四个关键项

```bash
# 1. CLI 连接配置 - 告诉 CLI 连接到哪个网关
gateway.remote.url = "ws://127.0.0.1:9999"

# 2. CLI 认证配置 - 告诉 CLI 使用什么 token
gateway.remote.token = "my-fixed-openclaw-token-please-change-this-in-production"

# 3. 网关认证配置 - 告诉网关接受什么 token（关键！）
gateway.auth.token = "my-fixed-openclaw-token-please-change-this-in-production"

# 4. 网关认证模式 - 告诉网关使用 token 认证（关键！）
gateway.auth.mode = "token"
```

### 配置文件示例

```json
{
  "gateway": {
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

## 🚀 使用方法

### 重新部署（应用新配置）

```bash
# 停止现有容器
docker compose --env-file .env.docker down

# 重新部署（会自动配置所有认证设置）
./scripts/docker-deploy.sh
```

### 或者手动配置

```bash
# 配置 CLI 连接
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:9999"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.token "my-fixed-openclaw-token-please-change-this-in-production"

# 配置网关认证（关键！）
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.auth.token "my-fixed-openclaw-token-please-change-this-in-production"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.auth.mode "token"

# 重启网关
docker compose --env-file .env.docker restart openclaw-gateway
```

## 📋 验证步骤

### 检查配置

```bash
# 检查 CLI 配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote

# 检查网关认证配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.auth
```

预期输出：

```json
{
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
```

### 测试连接

```bash
# 测试网关状态（应该不需要输入 token）
docker compose --env-file .env.docker run --rm openclaw-cli gateway status

# 运行完整测试
./scripts/docker-test.sh
```

## 🔧 工作原理

```
1. 用户执行 docker-start.sh
    ↓
2. 脚本配置 gateway.remote.url
    ↓
3. 脚本配置 gateway.remote.token
    ↓
4. 脚本配置 gateway.auth.token（关键！）
    ↓
5. 脚本配置 gateway.auth.mode = token（关键！）
    ↓
6. 网关重启，加载新的认证配置
    ↓
7. CLI 连接到网关，使用配置的 token
    ↓
8. 网关验证 token，认证成功
    ↓
✅ 用户直接使用，无需手动输入 token
```

## 💡 关键点

### 为什么之前需要输入 token？

之前只配置了 `gateway.remote.token`，告诉 CLI 使用什么 token，但没有配置 `gateway.auth.token`，网关不知道应该接受这个 token。

### 现在为什么不需要了？

现在同时配置了：

- `gateway.remote.token` - CLI 知道用什么 token
- `gateway.auth.token` - 网关知道接受什么 token
- `gateway.auth.mode = "token"` - 网关使用 token 认证模式

两边都配置好，实现完全自动化。

## 📝 注意事项

1. **Token 必须一致**: `gateway.remote.token` 和 `gateway.auth.token` 必须使用相同的值
2. **网关需要重启**: 修改 `gateway.auth.*` 配置后需要重启网关
3. **环境变量优先**: 如果设置了 `OPENCLAW_GATEWAY_TOKEN` 环境变量，它会覆盖配置文件中的设置
4. **安全性**: 生产环境请使用更强的 token

## 🎯 完成标志

当看到以下内容时，说明配置成功：

- ✅ 网关状态查询不需要输入 token
- ✅ 测试脚本全部通过
- ✅ 可以直接使用 CLI 命令
- ✅ 网页控制面板可以直接访问

## 📚 相关文档

- [Docker 部署指南](DOCKER_DEPLOY.md)
- [自动连接修复说明](DOCKER_AUTOCONNECT_FIX.md)
- [脚本使用指南](scripts/README.md)
- [快速参考](scripts/QUICK_REFERENCE.md)

## 🎉 完成后

现在你可以：

1. 运行 `./scripts/docker-start.sh` 启动服务
2. 直接使用 CLI 命令，无需输入 token
3. 访问 http://localhost:9999/ 使用网页控制面板
4. 享受完全自动化的体验！

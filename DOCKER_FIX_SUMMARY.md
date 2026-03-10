# OpenClaw Docker 自动连接 - 配置修复

## 🔧 问题修复

### 发现的问题

在配置自动连接时，脚本尝试设置 `gateway.remote.enabled = "true"`，但这个配置项不存在，导致配置验证失败。

### 修复内容

#### 1. 移除无效配置项

从所有脚本中移除了 `gateway.remote.enabled` 配置：

- ✅ `scripts/docker-deploy.sh`
- ✅ `scripts/docker-start.sh`
- ✅ `scripts/docker-update.sh`
- ✅ `scripts/docker-test.sh`

#### 2. 更新文档

更新了所有文档中的配置说明：

- ✅ `DOCKER_AUTOCONNECT_FIX.md`
- ✅ `scripts/README.md`
- ✅ `scripts/QUICK_REFERENCE.md`
- ✅ `DOCKER_IMPROVEMENTS_SUMMARY.md`

#### 3. 修正工作原理说明

添加了重要说明：**不需要设置 `gateway.remote.enabled`，只要设置了 `gateway.remote.url`，远程连接就会自动激活。**

## ✅ 正确的配置

### 自动连接配置（只需两项）

```bash
gateway.remote.url = "ws://127.0.0.1:9999"
gateway.remote.token = "my-fixed-openclaw-token-please-change-this-in-production"
```

### 配置文件示例

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

**注意**: 配置中不需要 `enabled` 字段。

## 🚀 使用方法

### 重新部署（如果之前遇到错误）

```bash
# 停止现有容器
docker compose --env-file .env.docker down

# 重新部署
./scripts/docker-deploy.sh
```

### 日常使用

```bash
# 启动服务
./scripts/docker-start.sh

# 验证配置
./scripts/docker-test.sh
```

## 📋 验证步骤

### 检查配置

```bash
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote
```

预期输出：

```
{
  "url": "ws://127.0.0.1:9999",
  "token": "my-fixed-openclaw-token-please-change-this-in-production"
}
```

### 检查网关状态

```bash
docker compose --env-file .env.docker run --rm openclaw-cli gateway status
```

### 运行测试

```bash
./scripts/docker-test.sh
```

## 🎯 修复效果

### 修复前

```bash
Error: Config validation failed: gateway.remote: Unrecognized key: "enabled"
⚠  警告: 无法设置 gateway.remote.enabled
```

### 修复后

```bash
✓ 自动连接网关已配置
✅ 所有测试通过
```

## 📚 相关文档

- [Docker 部署指南](DOCKER_DEPLOY.md)
- [自动连接修复说明](DOCKER_AUTOCONNECT_FIX.md)
- [脚本使用指南](scripts/README.md)
- [快速参考](scripts/QUICK_REFERENCE.md)

## ✅ 完成状态

- ✅ 移除无效配置项
- ✅ 更新所有脚本
- ✅ 更新所有文档
- ✅ 通过 lint 检查
- ✅ 配置验证通过

现在可以正常使用自动连接功能了！

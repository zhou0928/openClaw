# OpenClaw Docker 脚本使用指南

## 📚 脚本列表

### 1. `docker-deploy.sh` - 一键部署脚本（首次使用）

**用途**: 首次部署 OpenClaw Docker 服务

**功能**:

- 检查 Docker 和 Docker Compose 环境
- 读取 `.env.docker` 配置文件
- 停止本地运行的 OpenClaw 网关
- 清除端口占用
- 清理旧的 Docker 容器
- 构建 Docker 镜像（可选择跳过）
- 创建必要的配置和工作空间目录
- 配置 Control UI allowedOrigins
- 启动 Docker 容器
- 等待容器启动
- 检查容器状态
- 显示访问信息

**使用方法**:

```bash
./scripts/docker-deploy.sh
```

**何时使用**:

- 第一次部署 OpenClaw
- 完全重新部署（清除所有数据和配置）

---

### 2. `docker-start.sh` - 快速启动脚本

**用途**: 快速启动已部署的 OpenClaw Docker 容器

**功能**:

- 检查容器是否已运行
- 如果已运行，显示访问信息
- 如果未运行，启动容器
- 等待服务启动
- 检查容器状态
- 显示访问信息

**使用方法**:

```bash
./scripts/docker-start.sh
```

**何时使用**:

- 每次开机后启动 OpenClaw
- 停止容器后重新启动
- 日常启动服务

**优势**:

- ✅ 无需重新构建镜像
- ✅ 快速启动（3-5秒）
- ✅ 自动检查运行状态
- ✅ 显示清晰的访问信息
- ✅ **自动配置连接到网关**
- ✅ **无需手动输入 Token**
- ✅ **无需手动连接网关**

---

### 3. `docker-stop.sh` - 快速停止脚本

**用途**: 快速停止 OpenClaw Docker 容器

**功能**:

- 检查容器是否在运行
- 停止容器
- 显示提示信息

**使用方法**:

```bash
./scripts/docker-stop.sh
```

**何时使用**:

- 需要停止 OpenClaw 服务
- 释放系统资源
- 重启服务前先停止

---

### 4. `docker-update.sh` - 更新部署脚本

**用途**: 更新 OpenClaw 代码并重新部署

**功能**:

- 停止当前容器
- 清除端口占用
- 重新构建镜像
- 启动新容器
- 检查状态
- **重新配置自动连接**

**使用方法**:

```bash
./scripts/docker-update.sh
```

**何时使用**:

- 代码更新后
- 需要更新 Docker 镜像
- 修复问题后重新部署

---

## 🎯 推荐工作流程

### 首次部署

```bash
# 1. 首次部署
./scripts/docker-deploy.sh

# 2. 部署完成后，访问 http://localhost:9999/
# 使用 Token: my-fixed-openclaw-token-please-change-this-in-production
```

### 日常使用

```bash
# 每次开机后
./scripts/docker-start.sh

# 使用完毕后
./scripts/docker-stop.sh
```

### 代码更新后

```bash
# 1. 更新代码（如果需要）
git pull

# 2. 重新部署
./scripts/docker-update.sh
```

---

## ⚙️ 配置文件说明

### `.env.docker` 配置文件

主要配置项：

```bash
# 网关端口
OPENCLAW_GATEWAY_PORT=9999

# 网关绑定模式（lan: 局域网访问, loopback: 本地访问）
OPENCLAW_GATEWAY_BIND=lan

# 网关 Token（固定，无需每次输入）
OPENCLAW_GATEWAY_TOKEN=my-fixed-openclaw-token-please-change-this-in-production

# 配置目录（挂载到容器）
OPENCLAW_CONFIG_DIR=~/.openclaw

# 工作空间目录（挂载到容器）
OPENCLAW_WORKSPACE_DIR=~/.openclaw/workspace

# Docker 镜像名称
OPENCLAW_IMAGE=openclaw:local

# 安全选项（开发环境可设为 true）
OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=true
```

### 修改配置

```bash
# 编辑配置文件
nano .env.docker

# 修改后重启容器
docker compose --env-file .env.docker restart
```

---

## 🔍 故障排除

### 脚本无执行权限

```bash
chmod +x scripts/docker-*.sh
```

### 还是需要手动连接网关？

如果自动连接不起作用，请检查：

```bash
# 1. 检查配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote

# 2. 手动重新配置自动连接
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:9999"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.token "my-fixed-openclaw-token-please-change-this-in-production"

# 3. 重启容器
docker compose --env-file .env.docker restart
```

### 端口被占用

### 脚本无执行权限

```bash
chmod +x scripts/docker-*.sh
```

### 端口被占用

```bash
# 查看占用端口的进程
lsof -i :9999

# 终止占用进程
lsof -ti :9999 | xargs kill -9

# 或重新运行部署脚本，会自动处理
./scripts/docker-deploy.sh
```

### 容器无法启动

```bash
# 查看日志
docker compose --env-file .env.docker logs -f openclaw-gateway

# 查看容器状态
docker compose --env-file .env.docker ps

# 查看容器详细信息
docker compose --env-file .env.docker inspect openclaw-gateway
```

### Token 不正确

```bash
# 查看 Token
grep OPENCLAW_GATEWAY_TOKEN .env.docker

# 确认容器使用的是正确的 Token
docker compose --env-file .env.docker exec openclaw-gateway env | grep TOKEN
```

---

## 💡 最佳实践

1. **首次部署**: 使用 `docker-deploy.sh` 完整部署
2. **日常启动**: 使用 `docker-start.sh` 快速启动
3. **停止服务**: 使用 `docker-stop.sh` 快速停止
4. **代码更新**: 使用 `docker-update.sh` 更新部署
5. **配置修改**: 编辑 `.env.docker` 后重启容器
6. **查看日志**: 使用 `docker compose --env-file .env.docker logs -f`
7. **进入容器**: 使用 `docker compose --env-file .env.docker exec openclaw-cli bash`
8. **验证连接**: 使用 `docker compose --env-file .env.docker run --rm openclaw-cli gateway status`

---

## 📚 相关文档

- [Docker 部署完整指南](../DOCKER_DEPLOY.md)
- [项目主文档](../README.md)
- [配置文档](../docs/configuration/)

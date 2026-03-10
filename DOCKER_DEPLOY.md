# 🐳 OpenClaw Docker 快速部署指南

## 🚀 一键部署（首次使用）

```bash
./scripts/docker-deploy.sh
```

## ⚡ 快速启动（已部署）

```bash
./scripts/docker-start.sh
```

## 🛑 快速停止

```bash
./scripts/docker-stop.sh
```

## 🔄 更新部署

```bash
./scripts/docker-update.sh
```

## 🧪 测试部署

```bash
./scripts/docker-test.sh
```

## 📋 脚本功能

部署脚本会自动完成以下步骤：

1. ✅ **检查环境** - 验证 Docker 和 Docker Compose
2. ✅ **读取配置** - 从 `.env` 文件读取配置
3. ✅ **停止本地服务** - 停止本地运行的 OpenClaw 网关
4. ✅ **清除端口占用** - 检测并清除端口 99999 的占用
5. ✅ **清理旧容器** - 停止并删除旧的 OpenClaw 容器
6. ✅ **构建镜像** - 构建 Docker 镜像（可选择跳过）
7. ✅ **创建目录** - 创建配置和工作空间目录
8. ✅ **启动容器** - 使用 docker-compose 启动
9. ✅ **等待启动** - 等待容器完全启动
10. ✅ **显示状态** - 显示容器运行状态

## 🔧 配置说明

### 端口配置

在 `.env.docker` 文件中：

```bash
OPENCLAW_GATEWAY_PORT=9999
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_TOKEN=my-fixed-openclaw-token-please-change-this-in-production
```

## 📊 访问信息

部署完成后，访问：

- **网页控制面板**: http://localhost:9999/
- **Gateway Token**: `my-fixed-openclaw-token-please-change-this-in-production`

## ✅ 自动启动配置

已配置自动启动功能：

1. **固定 Token** - 每次使用相同的 Token，无需重新输入
2. **自动网关启动** - 容器启动时自动启动网关服务
3. **持久化配置** - 所有配置保存在 `~/.openclaw` 目录
4. **自动重启** - 容器崩溃后自动恢复（`restart: unless-stopped`）
5. **自动连接** - CLI 自动配置连接到本地网关，无需手动连接

### 自动连接工作原理

通过配置以下三个设置，让 CLI 自动连接到网关：

```bash
gateway.remote.url = "ws://127.0.0.1:9999"
gateway.remote.token = "my-fixed-openclaw-token-please-change-this-in-production"
gateway.remote.enabled = "true"
```

这些配置会在容器启动时自动设置，CLI 会自动连接到本地网关，无需手动操作。

部署完成后，只需：

1. 运行 `./scripts/docker-deploy.sh` 启动服务
2. 打开浏览器访问 http://localhost:9999/
3. 使用固定 Token 即可，无需每次输入
4. CLI 会自动连接到网关，无需手动连接

## 🔧 日常管理命令

```bash
# 查看所有容器状态
docker-compose ps

# 查看网关日志
docker-compose logs -f openclaw-gateway

# 查看所有日志
docker-compose logs -f

# 重启容器
docker-compose restart

# 停止容器
docker-compose down

# 完全清理（包括数据卷）
docker-compose down -v

# 进入 CLI 容器执行命令
docker-compose exec openclaw-cli bash

# 在容器中执行 OpenClaw 命令
docker-compose exec openclaw-cli openclaw channels list
docker-compose exec openclaw-cli openclaw models status
docker-compose exec openclaw-cli openclaw gateway status
```

## 🔄 更新部署

当代码更新后，运行更新脚本：

```bash
./scripts/docker-update.sh
```

更新脚本会：

1. 停止当前容器
2. 清除端口占用
3. 重新构建镜像
4. 启动新容器
5. 检查状态
6. **重新配置自动连接**

## 🎯 日常使用流程

### 第一次部署

```bash
./scripts/docker-deploy.sh
```

### 每次启动服务

```bash
./scripts/docker-start.sh
```

- ✅ 自动启动网关
- ✅ 自动配置连接
- ✅ 无需手动操作

### 每次停止服务

```bash
./scripts/docker-stop.sh
```

### 更新代码后重新部署

```bash
./scripts/docker-update.sh
```

## ✅ 自动化配置说明

### 固定 Token 配置

为了解决每次都需要输入 token 的问题，已配置以下自动化方案：

1. **固定 Token**: `.env.docker` 文件中设置固定的 `OPENCLAW_GATEWAY_TOKEN`
2. **自动传递**: Docker Compose 自动将 token 传递给容器
3. **网关自动启动**: 容器启动时自动启动网关服务
4. **持久化存储**: 所有配置保存在 `~/.openclaw` 目录

### 工作原理

```
.env.docker (固定 Token)
    ↓
docker-compose.yml (读取环境变量)
    ↓
容器启动时自动设置环境变量
    ↓
网关启动时自动读取 Token
    ↓
✅ 无需手动输入 Token
```

### 修改 Token

如果需要修改 token，只需编辑 `.env.docker` 文件：

```bash
# 编辑配置文件
nano .env.docker

# 修改这一行
OPENCLAW_GATEWAY_TOKEN=your-new-token-here

# 重启容器
docker compose --env-file .env.docker restart
```

## 🐛 故障排除

### 端口被占用

如果端口 99999 被占用：

```bash
# 查看占用端口的进程
lsof -i :99999

# 终止占用进程
lsof -ti :99999 | xargs kill -9
```

或者直接重新运行部署脚本，脚本会自动处理端口占用。

### 容器无法启动

```bash
# 查看详细日志
docker-compose logs openclaw-gateway

# 查看容器状态
docker-compose ps

# 查看容器详细信息
docker inspect openclaw-gateway
```

### 重新部署

如果需要完全重新部署：

```bash
# 停止并删除所有容器
docker-compose down

# 删除镜像
docker rmi openclaw:local

# 重新部署
./scripts/docker-deploy.sh
```

## 📁 数据持久化

配置和工作空间已挂载到本地目录：

- **配置**: `~/.openclaw` → `/home/node/.openclaw`
- **工作空间**: `~/.openclaw/workspace` → `/home/node/.openclaw/workspace`

这意味着：

- ✅ 配置修改会持久化
- ✅ 对话历史会保存
- ✅ 容器删除后数据不会丢失

## 🎯 快速测试

部署完成后，测试服务是否正常：

```bash
# 健康检查
curl http://localhost:99999/healthz

# 准备检查
curl http://localhost:99999/readyz
```

## 💡 提示

- 首次构建镜像需要 5-10 分钟
- 后续构建会使用缓存，速度更快
- 容器设置自动重启，崩溃后自动恢复
- 建议设置 OrbStack/Docker 开机自启动
- Token 已固定，启动后即可直接使用，无需每次输入
- 配置保存在 `~/.openclaw`，容器重启不会丢失配置
- **CLI 自动连接到网关，无需手动连接**

## 🎯 常见问题

### Q: 还是需要手动连接网关？

A: 如果遇到这种情况，请检查：

1. 确保使用了 `./scripts/docker-start.sh` 启动服务
2. 检查配置文件 `~/.openclaw/openclaw.json` 中是否有 `gateway.remote.url` 设置
3. 手动运行以下命令重新配置：

```bash
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:9999"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.token "your-token"
docker compose --env-file .env.docker run --rm openclaw-cli config set gateway.remote.enabled "true"
```

### Q: 为什么需要 Token？

### Q: 为什么需要 Token？

A: Token 用于保护 OpenClaw 网关服务，防止未授权访问。在本地开发环境中，使用固定 Token 可以简化操作流程。

### Q: Token 会自动生成吗？

A: 不会。我们在 `.env.docker` 文件中设置了一个固定的 Token，每次启动都会使用相同的 Token。

### Q: 可以不使用 Token 吗？

A: 不建议。生产环境中 Token 是必需的安全措施。如果测试环境确实需要，可以将 `OPENCLAW_GATEWAY_TOKEN` 设置为空字符串，但会降低安全性。

### Q: 如何查看当前 Token？

A: 查看配置文件：

```bash
grep OPENCLAW_GATEWAY_TOKEN .env.docker
```

### Q: 容器重启后需要重新配置吗？

A: 不需要。所有配置都保存在 `~/.openclaw` 目录，容器重启会自动读取这些配置。

### Q: 如何让 Docker 开机自动启动？

A:

```bash
# macOS with OrbStack
# OrbStack 应用会自动启动

# macOS with Docker Desktop
# 在 Docker Desktop 设置中启用 "Start Docker Desktop when you log in"

# Linux
sudo systemctl enable docker
```

## 📝 注意事项

1. **端口冲突**: 确保端口 9999 没有被其他服务占用
2. **防火墙**: 如果需要外部访问，需开放端口 9999
3. **资源限制**: 可根据需要调整 Docker 资源限制
4. **安全**: 生产环境建议使用更强的 Token

## ✅ 验证步骤

启动后，验证自动连接是否正常：

```bash
# 运行测试脚本（推荐）
./scripts/docker-test.sh

# 或手动验证：
# 1. 检查容器状态
docker compose --env-file .env.docker ps

# 2. 检查网关日志
docker compose --env-file .env.docker logs -f openclaw-gateway

# 3. 检查配置
docker compose --env-file .env.docker run --rm openclaw-cli config get gateway.remote

# 4. 测试连接
docker compose --env-file .env.docker run --rm openclaw-cli gateway status
```

## 🎉 完成

部署成功后，访问 http://localhost:9999/ 开始使用 OpenClaw！

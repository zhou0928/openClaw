#!/bin/bash

# OpenClaw Docker 更新脚本
# 功能：停止容器、重新构建镜像、启动新容器、自动清理端口占用

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔄 OpenClaw Docker 更新脚本"
echo "=============================="

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 读取环境变量
ENV_FILE=".env.docker"
cd "$PROJECT_ROOT" || exit 1
if [ -f "$ENV_FILE" ]; then
    GATEWAY_PORT=$(grep "OPENCLAW_GATEWAY_PORT" "$ENV_FILE" | cut -d'=' -f2)
else
    GATEWAY_PORT=9999
fi

# 1. 停止并删除旧容器
echo ""
echo -e "${BLUE}📋 步骤 1: 停止容器...${NC}"
cd "$PROJECT_ROOT" || exit 1
docker compose --env-file "$ENV_FILE" down 2>/dev/null || docker-compose --env-file "$ENV_FILE" down 2>/dev/null || true
echo -e "${GREEN}✓${NC} 容器已停止"

# 2. 清除端口占用（如果有的话）
echo ""
echo -e "${BLUE}📋 步骤 2: 检查端口占用...${NC}"
if lsof -i ":${GATEWAY_PORT}" 2>/dev/null | grep -q LISTEN; then
    echo -e "${YELLOW}⚠${NC}  端口 $GATEWAY_PORT 被占用"
    lsof -ti ":${GATEWAY_PORT}" | xargs kill -9 2>/dev/null || true
    echo -e "${GREEN}✓${NC} 端口占用已清除"
else
    echo -e "${GREEN}✓${NC} 端口可用"
fi

# 3. 重新构建镜像
echo ""
echo -e "${BLUE}📋 步骤 3: 重新构建镜像...${NC}"
docker build -t openclaw:local "$PROJECT_ROOT"
echo -e "${GREEN}✓${NC} 镜像构建完成"

# 4. 启动新容器
echo ""
echo -e "${BLUE}📋 步骤 4: 启动新容器...${NC}"
docker compose --env-file "$ENV_FILE" up -d
echo -e "${GREEN}✓${NC} 容器已启动"

# 5. 等待容器启动
echo ""
echo -e "${BLUE}📋 步骤 5: 等待容器启动...${NC}"
sleep 5

# 6. 检查容器状态
echo ""
echo -e "${BLUE}📋 步骤 6: 检查容器状态...${NC}"
docker compose --env-file "$ENV_FILE" ps

# 7. 确保自动连接配置
echo ""
echo -e "${BLUE}📋 步骤 7: 确保自动连接配置...${NC}"
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:${GATEWAY_PORT}" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.remote.url"
}
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.remote.token "$GATEWAY_TOKEN" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.remote.token"
}
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.auth.token "$GATEWAY_TOKEN" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.auth.token"
}
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.auth.mode "token" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.auth.mode"
}
echo -e "${GREEN}✓${NC} 自动连接网关已配置"

echo ""
echo -e "${GREEN}✅ 更新完成！${NC}"
echo "访问: http://localhost:${GATEWAY_PORT}/"
echo "Token: $GATEWAY_TOKEN"

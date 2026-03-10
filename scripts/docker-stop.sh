#!/bin/bash

# OpenClaw 快速停止脚本
# 用于快速停止 Docker 容器

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env.docker"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（脚本所在目录的上一级）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

echo -e "${BLUE}🛑 OpenClaw 快速停止${NC}"
echo "=================="

# 检查容器是否在运行
if docker compose --env-file "$ENV_FILE" ps | grep -q "openclaw-gateway.*Up"; then
    echo -e "${YELLOW}⚠${NC}  停止 OpenClaw 容器..."
    docker compose --env-file "$ENV_FILE" down
    echo -e "${GREEN}✅ 容器已停止${NC}"
else
    echo -e "${YELLOW}⚠${NC}  OpenClaw 容器未运行"
fi

echo ""
echo "💡 提示："
echo "   - 重新启动: ./scripts/docker-start.sh"
echo "   - 完全重新部署: ./scripts/docker-deploy.sh"

#!/bin/bash

# OpenClaw 快速启动脚本
# 用于快速启动 Docker 容器，无需每次重新部署

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

echo -e "${BLUE}🚀 OpenClaw 快速启动${NC}"
echo "=================="

# 读取配置
if [ -f "$ENV_FILE" ]; then
    GATEWAY_PORT=$(grep "OPENCLAW_GATEWAY_PORT" "$ENV_FILE" | cut -d'=' -f2)
    GATEWAY_TOKEN=$(grep "OPENCLAW_GATEWAY_TOKEN" "$ENV_FILE" | cut -d'=' -f2)
    
    echo -e "${GREEN}✓${NC} 配置文件: $ENV_FILE"
    echo -e "  - 端口: $GATEWAY_PORT"
else
    echo -e "${YELLOW}⚠${NC}  未找到 $ENV_FILE，使用默认配置"
    GATEWAY_PORT=9999
    GATEWAY_TOKEN="my-fixed-openclaw-token-please-change-this-in-production"
fi

# 检查容器是否已运行
if docker compose --env-file "$ENV_FILE" ps | grep -q "openclaw-gateway.*Up"; then
    echo -e "${YELLOW}⚠${NC}  OpenClaw 容器已在运行"
    echo ""
    echo "📋 访问信息："
    echo "   - 网页控制面板: http://localhost:${GATEWAY_PORT}/"
    echo "   - Gateway Token: $GATEWAY_TOKEN"
    echo ""
    echo "🔧 常用命令："
    echo "   - 查看日志: docker compose --env-file $ENV_FILE logs -f"
    echo "   - 停止服务: docker compose --env-file $ENV_FILE down"
    echo "   - 重启服务: docker compose --env-file $ENV_FILE restart"
    exit 0
fi

# 启动容器
echo ""
echo -e "${BLUE}📋 启动容器...${NC}"
docker compose --env-file "$ENV_FILE" up -d

# 等待启动
echo ""
echo -e "${BLUE}📋 等待服务启动...${NC}"
sleep 5

# 检查状态
echo ""
docker compose --env-file "$ENV_FILE" ps

# 确保自动连接配置
echo ""
echo -e "${BLUE}📋 确保自动连接配置...${NC}"
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

# 显示结果
echo ""
echo -e "${GREEN}✅ 启动完成！${NC}"
echo ""
echo "📋 访问信息："
echo "   - 网页控制面板: http://localhost:${GATEWAY_PORT}/"
echo "   - 自动登录页面: file://${PROJECT_ROOT}/auto-login.html"
echo "   - Gateway Token: $GATEWAY_TOKEN"
echo ""
echo "🔧 常用命令："
echo "   - 查看日志: docker compose --env-file $ENV_FILE logs -f"
echo "   - 查看网关日志: docker compose --env-file $ENV_FILE logs -f openclaw-gateway"
echo "   - 停止服务: docker compose --env-file $ENV_FILE down"
echo "   - 重启服务: docker compose --env-file $ENV_FILE restart"
echo ""
echo "💡 提示："
echo "   - Token 已固定，无需每次输入"
echo "   - 网关自动启动，可直接使用"
echo "   - CLI 已配置自动连接到网关"
echo ""
echo -e "${BLUE}🎉 正在自动打开浏览器...${NC}"

# 自动打开浏览器（使用 auto-login.html 实现自动填写 token）
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "file://${PROJECT_ROOT}/auto-login.html"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        xdg-open "file://${PROJECT_ROOT}/auto-login.html"
    else
        echo -e "${YELLOW}⚠${NC}  请手动打开浏览器访问: file://${PROJECT_ROOT}/auto-login.html"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    start "" "file://${PROJECT_ROOT}/auto-login.html"
else
    echo -e "${YELLOW}⚠${NC}  请手动打开浏览器访问: file://${PROJECT_ROOT}/auto-login.html"
fi

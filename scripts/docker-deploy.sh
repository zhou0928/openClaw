#!/bin/bash

# OpenClaw Docker 一键部署脚本
# 功能：清理旧容器、清除端口占用、构建镜像、启动新容器

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
IMAGE_NAME="openclaw:local"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env.docker"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（脚本所在目录的上一级）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🦞 OpenClaw Docker 一键部署脚本"
echo "================================"

# 1. 检查 Docker
echo ""
echo -e "${BLUE}📋 步骤 1: 检查环境...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker 已安装: $(docker --version)"

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker Compose 已就绪"

# 2. 读取环境变量
echo ""
echo -e "${BLUE}📋 步骤 2: 读取配置...${NC}"
cd "$PROJECT_ROOT" || exit 1
if [ -f "$ENV_FILE" ]; then
    # 读取端口配置
    GATEWAY_PORT=$(grep "OPENCLAW_GATEWAY_PORT" "$ENV_FILE" | cut -d'=' -f2)
    GATEWAY_BIND=$(grep "OPENCLAW_GATEWAY_BIND" "$ENV_FILE" | cut -d'=' -f2)
    GATEWAY_TOKEN=$(grep "OPENCLAW_GATEWAY_TOKEN" "$ENV_FILE" | cut -d'=' -f2)
    
    echo -e "${GREEN}✓${NC} 配置文件: $ENV_FILE"
    echo -e "  - 端口: $GATEWAY_PORT"
    echo -e "  - 绑定模式: $GATEWAY_BIND"
    echo -e "  - Token: $GATEWAY_TOKEN (固定 Token，无需每次输入)"
else
    echo -e "${YELLOW}⚠${NC}  未找到 $ENV_FILE，使用默认配置"
    GATEWAY_PORT=9999
    GATEWAY_BIND=lan
    GATEWAY_TOKEN="5f6a2372c8714083555881cc937a5a99e054a98068f5e1b2256ee99a2a6e4470"
fi

# 3. 停止本地运行的网关
echo ""
echo -e "${BLUE}📋 步骤 3: 停止本地服务...${NC}"
if pgrep -f "openclaw.*gateway" > /dev/null; then
    echo "  停止本地 OpenClaw 网关..."
    pkill -9 -f "openclaw.*gateway" 2>/dev/null || true
    sleep 2
    echo -e "${GREEN}✓${NC} 本地网关已停止"
else
    echo -e "${GREEN}✓${NC} 无本地网关运行"
fi

# 4. 清除端口占用
echo ""
echo -e "${BLUE}📋 步骤 4: 检查端口占用...${NC}"
PORT_OCCUPIED=false

# 检查是否是 Docker 容器占用了端口
if docker ps --format "{{.Ports}}" | grep -q ":${GATEWAY_PORT}"; then
    echo -e "${YELLOW}⚠${NC}  端口 $GATEWAY_PORT 被其他 Docker 容器占用"
    echo -e "${YELLOW}ℹ${NC}  将在步骤 5 中清理旧容器"
fi

# 检查系统进程占用（排除 OrbStack 和 Docker）
if lsof -i ":${GATEWAY_PORT}" 2>/dev/null | grep LISTEN | grep -v OrbStack | grep -v com.docker | grep -q .; then
    echo -e "${YELLOW}⚠${NC}  端口 $GATEWAY_PORT 被其他进程占用"
    lsof -i ":${GATEWAY_PORT}" 2>/dev/null | grep LISTEN | grep -v OrbStack | grep -v com.docker
    echo ""
    read -p "  是否终止占用进程？[y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 只终止非 OrbStack 和非 Docker 的进程
        lsof -ti ":${GATEWAY_PORT}" 2>/dev/null | while read -r pid; do
            if ps -p "$pid" -o command= | grep -vq -E "OrbStack|Docker"; then
                kill -9 "$pid" 2>/dev/null || true
            fi
        done
        echo -e "${GREEN}✓${NC} 进程已终止"
    else
        echo -e "${RED}❌${NC} 部署中止"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} 端口 $GATEWAY_PORT 检查完成"

# 5. 停止并删除旧容器
echo ""
echo -e "${BLUE}📋 步骤 5: 清理旧容器...${NC}"
cd "$PROJECT_ROOT" || exit 1
if [ -f "$COMPOSE_FILE" ]; then
    docker compose --env-file "$ENV_FILE" down 2>/dev/null || docker-compose --env-file "$ENV_FILE" down 2>/dev/null || true
    echo -e "${GREEN}✓${NC} 旧容器已清理"
else
    echo -e "${YELLOW}⚠${NC}  未找到 $COMPOSE_FILE"
fi

# 删除所有 OpenClaw 相关容器（以防万一）
OLD_CONTAINERS=$(docker ps -a --filter "name=openclaw" --format "{{.ID}}")
if [ -n "$OLD_CONTAINERS" ]; then
    echo "  删除残留的 OpenClaw 容器..."
    docker ps -a --filter "name=openclaw" --format "{{.ID}}" | xargs docker rm -f 2>/dev/null || true
fi
echo -e "${GREEN}✓${NC} 清理完成"

# 6. 构建或使用现有镜像
echo ""
echo -e "${BLUE}📋 步骤 6: 构建 Docker 镜像...${NC}"
cd "$PROJECT_ROOT" || exit 1
if docker images | grep -q "openclaw.*local"; then
    echo -e "${YELLOW}ℹ${NC}  检测到现有镜像"
    read -p "  是否重新构建？[y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "  开始构建镜像（可能需要几分钟）..."
        docker build -t "$IMAGE_NAME" "$PROJECT_ROOT"
        echo -e "${GREEN}✓${NC} 镜像构建完成"
    else
        echo -e "${GREEN}✓${NC} 使用现有镜像"
    fi
else
    echo "  开始构建镜像（首次构建可能需要几分钟）..."
    docker build -t "$IMAGE_NAME" "$PROJECT_ROOT"
    echo -e "${GREEN}✓${NC} 镜像构建完成"
fi

# 7. 创建必要的目录
echo ""
echo -e "${BLUE}📋 步骤 7: 创建必要的目录...${NC}"
CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"

mkdir -p "$CONFIG_DIR"
mkdir -p "$WORKSPACE_DIR"
echo -e "${GREEN}✓${NC} 配置目录: $CONFIG_DIR"
echo -e "${GREEN}✓${NC} 工作空间: $WORKSPACE_DIR"

# 8. 配置自动连接网关
echo ""
echo -e "${BLUE}📋 步骤 8: 配置自动连接网关...${NC}"

cd "$PROJECT_ROOT" || exit 1

# 配置 Control UI allowedOrigins (lan 模式需要)
if [ "$GATEWAY_BIND" = "lan" ]; then
    echo "  为 lan 模式配置 allowedOrigins..."
    
    # 构建 JSON 数组
    allowed_origin_json=$(cat <<EOF
[
  "http://localhost:${GATEWAY_PORT}",
  "http://127.0.0.1:${GATEWAY_PORT}"
]
EOF
)
    
    # 使用 docker compose 配置（容器启动前）
    docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.controlUi.allowedOrigins "$allowed_origin_json" --strict-json 2>/dev/null || {
        echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.controlUi.allowedOrigins"
    }
    echo -e "${GREEN}✓${NC} allowedOrigins 已配置"
fi

# 配置自动连接到本地网关（关键：让 CLI 自动连接）
echo "  配置自动连接到本地网关..."
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.remote.url "ws://127.0.0.1:${GATEWAY_PORT}" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.remote.url"
}
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.remote.token "$GATEWAY_TOKEN" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.remote.token"
}

# 配置网关认证（关键：让网关接受这个 token）
echo "  配置网关认证..."
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.auth.token "$GATEWAY_TOKEN" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.auth.token"
}
docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config set gateway.auth.mode "token" 2>/dev/null || {
    echo -e "${YELLOW}⚠${NC}  警告: 无法设置 gateway.auth.mode"
}
echo -e "${GREEN}✓${NC} 自动连接网关已配置"

# 9. 启动容器
echo ""
echo -e "${BLUE}📋 步骤 9: 启动 OpenClaw 容器...${NC}"
if [ -f "$PROJECT_ROOT/$COMPOSE_FILE" ]; then
    docker compose --env-file "$ENV_FILE" up -d
else
    echo -e "${RED}❌${NC} 未找到 $PROJECT_ROOT/$COMPOSE_FILE"
    exit 1
fi

# 10. 等待容器启动
echo ""
echo -e "${BLUE}📋 步骤 10: 等待容器启动...${NC}"
sleep 5

# 11. 检查容器状态
echo ""
echo -e "${BLUE}📋 步骤 11: 检查容器状态...${NC}"
docker compose --env-file "$ENV_FILE" ps

# 12. 显示部署结果
echo ""
echo -e "${GREEN}===================================="
echo "✅ 部署完成！"
echo "====================================${NC}"
echo ""
echo "📋 访问信息："
echo "   - 网页控制面板: http://localhost:${GATEWAY_PORT}/"
echo "   - 自动登录页面: file://${PROJECT_ROOT}/auto-login.html"
echo "   - Gateway Token: $GATEWAY_TOKEN"
echo ""
echo "✅ 自动配置完成："
echo "   - Token 已固定，无需每次输入"
echo "   - 容器会自动启动网关"
echo "   - 网关启动后即可直接使用"
echo ""
echo "🔧 常用命令："
echo "   - 查看日志: docker compose --env-file .env.docker logs -f"
echo "   - 查看网关日志: docker compose --env-file .env.docker logs -f openclaw-gateway"
echo "   - 查看状态: docker compose --env-file .env.docker ps"
echo "   - 重启容器: docker compose --env-file .env.docker restart"
echo "   - 停止容器: docker compose --env-file .env.docker down"
echo "   - 进入 CLI: docker compose --env-file .env.docker exec openclaw-cli bash"
echo ""
echo "🔄 更新部署:"
echo "   ./scripts/docker-update.sh"
echo ""
echo "💡 提示："
echo "   - 容器已设置为自动重启（restart: unless-stopped）"
echo "   - 配置和工作空间已挂载到本地目录"
echo "   - 即使 Docker 重启，数据也不会丢失"
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

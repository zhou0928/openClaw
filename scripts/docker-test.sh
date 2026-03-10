#!/bin/bash

# OpenClaw Docker 测试脚本
# 用于验证 Docker 部署和自动连接功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
ENV_FILE=".env.docker"
COMPOSE_FILE="docker-compose.yml"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（脚本所在目录的上一级）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

echo -e "${BLUE}🧪 OpenClaw Docker 测试脚本${NC}"
echo "========================="
echo ""

# 读取配置
if [ -f "$ENV_FILE" ]; then
    GATEWAY_PORT=$(grep "OPENCLAW_GATEWAY_PORT" "$ENV_FILE" | cut -d'=' -f2)
    GATEWAY_TOKEN=$(grep "OPENCLAW_GATEWAY_TOKEN" "$ENV_FILE" | cut -d'=' -f2)
    echo -e "${GREEN}✓${NC} 配置文件存在"
    echo -e "  - 端口: $GATEWAY_PORT"
    echo -e "  - Token: ${GATEWAY_TOKEN:0:20}..."
else
    echo -e "${RED}❌${NC} 配置文件 $ENV_FILE 不存在"
    exit 1
fi

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_passed() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

test_failed() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

echo ""
echo -e "${BLUE}📋 测试 1: 检查 Docker 环境${NC}"

if command -v docker &> /dev/null; then
    test_passed "Docker 已安装: $(docker --version)"
else
    test_failed "Docker 未安装"
fi

if docker compose version &> /dev/null || docker-compose version &> /dev/null; then
    test_passed "Docker Compose 已就绪"
else
    test_failed "Docker Compose 未安装"
fi

echo ""
echo -e "${BLUE}📋 测试 2: 检查容器状态${NC}"

if docker compose --env-file "$ENV_FILE" ps | grep -q "openclaw-gateway.*Up"; then
    test_passed "Gateway 容器正在运行"
else
    test_failed "Gateway 容器未运行"
fi

if docker compose --env-file "$ENV_FILE" ps | grep -q "openclaw-cli.*Up"; then
    test_passed "CLI 容器正在运行"
else
    test_failed "CLI 容器未运行"
fi

echo ""
echo -e "${BLUE}📋 测试 3: 检查端口监听${NC}"

if lsof -i ":${GATEWAY_PORT}" 2>/dev/null | grep -q LISTEN; then
    test_passed "端口 $GATEWAY_PORT 正在监听"
else
    test_failed "端口 $GATEWAY_PORT 未监听"
fi

echo ""
echo -e "${BLUE}📋 测试 4: 检查网关健康状态${NC}"

if curl -s "http://127.0.0.1:${GATEWAY_PORT}/healthz" > /dev/null 2>&1; then
    test_passed "网关健康检查通过"
else
    test_failed "网关健康检查失败"
fi

echo ""
echo -e "${BLUE}📋 测试 5: 检查自动连接配置${NC}"

GATEWAY_REMOTE_URL=$(docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config get gateway.remote.url 2>/dev/null || echo "")
if [ "$GATEWAY_REMOTE_URL" = "ws://127.0.0.1:${GATEWAY_PORT}" ]; then
    test_passed "gateway.remote.url 配置正确"
else
    test_failed "gateway.remote.url 配置不正确: $GATEWAY_REMOTE_URL"
fi

GATEWAY_REMOTE_TOKEN=$(docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config get gateway.remote.token 2>/dev/null || echo "")
if [ -n "$GATEWAY_REMOTE_TOKEN" ]; then
    test_passed "gateway.remote.token 已配置"
else
    test_failed "gateway.remote.token 未配置"
fi

GATEWAY_AUTH_TOKEN=$(docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config get gateway.auth.token 2>/dev/null || echo "")
if [ -n "$GATEWAY_AUTH_TOKEN" ]; then
    test_passed "gateway.auth.token 已配置"
else
    test_failed "gateway.auth.token 未配置"
fi

GATEWAY_AUTH_MODE=$(docker compose --env-file "$ENV_FILE" run --rm openclaw-cli config get gateway.auth.mode 2>/dev/null || echo "")
if [ "$GATEWAY_AUTH_MODE" = "token" ]; then
    test_passed "gateway.auth.mode 已设置为 token"
else
    test_failed "gateway.auth.mode 未正确设置: $GATEWAY_AUTH_MODE"
fi

echo ""
echo -e "${BLUE}📋 测试 6: 检查网关状态${NC}"

GATEWAY_STATUS=$(docker compose --env-file "$ENV_FILE" run --rm openclaw-cli gateway status 2>/dev/null || echo "")
if [ -n "$GATEWAY_STATUS" ]; then
    test_passed "网关状态可查询"
else
    test_failed "网关状态查询失败"
fi

echo ""
echo -e "${BLUE}📋 测试 7: 检查配置文件${NC}"

if [ -f "$ENV_FILE" ]; then
    test_passed ".env.docker 文件存在"
else
    test_failed ".env.docker 文件不存在"
fi

if [ -f "$COMPOSE_FILE" ]; then
    test_passed "docker-compose.yml 文件存在"
else
    test_failed "docker-compose.yml 文件不存在"
fi

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
if [ -d "$CONFIG_DIR" ]; then
    test_passed "配置目录存在: $CONFIG_DIR"
else
    test_failed "配置目录不存在: $CONFIG_DIR"
fi

if [ -f "$CONFIG_DIR/openclaw.json" ]; then
    test_passed "配置文件存在: $CONFIG_DIR/openclaw.json"
else
    test_failed "配置文件不存在: $CONFIG_DIR/openclaw.json"
fi

echo ""
echo -e "${BLUE}📋 测试 8: 检查脚本权限${NC}"

for script in scripts/docker-deploy.sh scripts/docker-start.sh scripts/docker-stop.sh scripts/docker-update.sh; do
    if [ -x "$script" ]; then
        test_passed "$script 有执行权限"
    else
        test_failed "$script 无执行权限"
    fi
done

echo ""
echo -e "${BLUE}📋 测试 9: 检查 Docker 镜像${NC}"

if docker images | grep -q "openclaw.*local"; then
    test_passed "Docker 镜像存在"
else
    test_failed "Docker 镜像不存在"
fi

echo ""
echo -e "${BLUE}📋 测试 10: 检查日志${NC}"

GATEWAY_LOGS=$(docker compose --env-file "$ENV_FILE" logs --tail=10 openclaw-gateway 2>/dev/null || echo "")
if [ -n "$GATEWAY_LOGS" ]; then
    test_passed "网关日志可读取"
else
    test_failed "网关日志不可读取"
fi

if echo "$GATEWAY_LOGS" | grep -q "listening"; then
    test_passed "网关正在监听（日志中找到 'listening'）"
else
    test_failed "网关可能未正常启动（日志中未找到 'listening'）"
fi

echo ""
echo "========================="
echo "测试结果:"
echo -e "  ${GREEN}通过: $TESTS_PASSED${NC}"
echo -e "  ${RED}失败: $TESTS_FAILED${NC}"
echo "========================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ 所有测试通过！OpenClaw Docker 部署和自动连接功能正常。${NC}"
    echo ""
    echo "📋 访问信息："
    echo "   - 网页控制面板: http://localhost:${GATEWAY_PORT}/"
    echo "   - Gateway Token: $GATEWAY_TOKEN"
    echo ""
    echo "🎉 现在可以在浏览器中访问 OpenClaw 了！"
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠${NC}  有 $TESTS_FAILED 个测试失败，请检查上述错误信息。"
    echo ""
    echo "💡 建议："
    echo "   - 运行 ./scripts/docker-deploy.sh 重新部署"
    echo "   - 查看日志: docker compose --env-file $ENV_FILE logs -f"
    echo "   - 检查配置: docker compose --env-file $ENV_FILE run --rm openclaw-cli config get gateway.remote"
    exit 1
fi

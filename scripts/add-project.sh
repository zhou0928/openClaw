#!/bin/bash

# OpenClaw 快速添加项目到 workspace 的脚本

set -e

echo "=== OpenClaw 项目映射工具 ==="

# 容器名称
CONTAINER="openclaws-openclaw-gateway-1"

# 检查容器是否运行
if ! docker ps | grep -q "$CONTAINER"; then
    echo "错误: OpenClaw 容器未运行"
    echo "请先启动容器: docker-compose up -d"
    exit 1
fi

echo "✓ OpenClaw 容器正在运行"
echo ""

# 显示可用项目列表
echo "可用的项目列表："
echo ""
docker exec $CONTAINER ls /home/node/workGroup
echo ""

# 如果有参数，直接映射该项目
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
    PROJECT_PATH="/home/node/workGroup/$PROJECT_NAME"
    WORKSPACE_LINK="/home/node/.openclaw/workspace/$PROJECT_NAME"

    # 检查项目是否存在
    if ! docker exec $CONTAINER test -d "$PROJECT_PATH"; then
        echo "错误: 项目不存在: $PROJECT_NAME"
        exit 1
    fi

    # 创建符号链接
    echo "正在映射项目: $PROJECT_NAME"
    docker exec $CONTAINER ln -sf "$PROJECT_PATH" "$WORKSPACE_LINK"

    # 验证
    if docker exec $CONTAINER test -L "$WORKSPACE_LINK"; then
        echo "✓ 项目映射成功！"
        echo ""
        echo "在 OpenClaw Control UI 中，可以通过以下路径访问该项目："
        echo "  ~/.openclaw/workspace/$PROJECT_NAME"
    else
        echo "错误: 项目映射失败"
        exit 1
    fi

    exit 0
fi

# 交互式选择
echo "请输入要映射的项目名称（或输入 'list' 查看列表，'all' 映射所有项目）："
read -r input

case "$input" in
    "list"|"l")
        echo ""
        echo "可用的项目列表："
        docker exec $CONTAINER ls /home/node/workGroup
        exit 0
        ;;
    "all"|"a")
        echo "正在映射所有项目..."
        PROJECTS=$(docker exec $CONTAINER ls /home/node/workGroup)
        COUNT=0
        for project in $PROJECTS; do
            PROJECT_PATH="/home/node/workGroup/$project"
            WORKSPACE_LINK="/home/node/.openclaw/workspace/$project"

            if docker exec $CONTAINER test -d "$PROJECT_PATH"; then
                docker exec $CONTAINER ln -sf "$PROJECT_PATH" "$WORKSPACE_LINK" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "✓ $project"
                    ((COUNT++))
                fi
            fi
        done
        echo ""
        echo "✓ 成功映射 $COUNT 个项目到 workspace"
        exit 0
        ;;
    *)
        if [ -z "$input" ]; then
            echo "错误: 请输入项目名称"
            exit 1
        fi

        PROJECT_NAME="$input"
        PROJECT_PATH="/home/node/workGroup/$PROJECT_NAME"
        WORKSPACE_LINK="/home/node/.openclaw/workspace/$PROJECT_NAME"

        # 检查项目是否存在
        if ! docker exec $CONTAINER test -d "$PROJECT_PATH"; then
            echo "错误: 项目不存在: $PROJECT_NAME"
            echo ""
            echo "可用的项目列表："
            docker exec $CONTAINER ls /home/node/workGroup
            exit 1
        fi

        # 创建符号链接
        echo "正在映射项目: $PROJECT_NAME"
        docker exec $CONTAINER ln -sf "$PROJECT_PATH" "$WORKSPACE_LINK"

        # 验证
        if docker exec $CONTAINER test -L "$WORKSPACE_LINK"; then
            echo "✓ 项目映射成功！"
            echo ""
            echo "在 OpenClaw Control UI 中，可以通过以下路径访问该项目："
            echo "  ~/.openclaw/workspace/$PROJECT_NAME"
        else
            echo "错误: 项目映射失败"
            exit 1
        fi
        ;;
esac

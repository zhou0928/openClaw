#!/bin/bash

# OrbStack 自动挂载 workGroup 目录脚本

set -e

echo "=== OrbStack 自动挂载配置 ==="

# 配置路径
WORKGROUP_HOST="/Users/xiaozhou/workGroup"
WORKGROUP_CONTAINER="/home/node/workGroup"
ORBSTACK_CONFIG_DIR="$HOME/.orbstack/config"

# 检查 workGroup 目录是否存在
if [ ! -d "$WORKGROUP_HOST" ]; then
    echo "错误: workGroup 目录不存在: $WORKGROUP_HOST"
    exit 1
fi

echo "✓ 找到 workGroup 目录: $WORKGROUP_HOST"

# 检查 OrbStack 配置目录
if [ ! -d "$ORBSTACK_CONFIG_DIR" ]; then
    echo "错误: OrbStack 配置目录不存在: $ORBSTACK_CONFIG_DIR"
    exit 1
fi

echo "✓ 找到 OrbStack 配置目录"

# 检查 OrbStack 是否在运行
if ! orbctl status > /dev/null 2>&1; then
    echo "OrbStack 未运行，正在启动..."
    orbctl start
    sleep 3
fi

echo "✓ OrbStack 正在运行"

# 尝试通过命令行添加挂载（需要管理员权限）
echo ""
echo "尝试添加挂载配置..."

# 方法 1: 尝试使用 orbctl 设置（如果支持）
# 注意：OrbStack 可能没有直接的命令行挂载 API

# 方法 2: 创建挂载配置文件
MOUNT_CONFIG="$ORBSTACK_CONFIG_DIR/mounts.json"

# 检查是否已存在挂载配置
if [ -f "$MOUNT_CONFIG" ]; then
    echo "发现现有挂载配置，检查是否包含 workGroup..."
    if grep -q "$WORKGROUP_HOST" "$MOUNT_CONFIG"; then
        echo "✓ workGroup 挂载已存在"
    else
        echo "正在添加 workGroup 挂载..."
        # 备份现有配置
        cp "$MOUNT_CONFIG" "$MOUNT_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    fi
else
    echo "创建新的挂载配置..."
fi

# 创建挂载配置
cat > "$MOUNT_CONFIG" << EOF
{
    "mounts": [
        {
            "source": "$WORKGROUP_HOST",
            "target": "$WORKGROUP_CONTAINER",
            "writable": true
        }
    ]
}
EOF

echo "✓ 已创建挂载配置文件: $MOUNT_CONFIG"

# 重启 OrbStack 以应用配置
echo ""
echo "需要重启 OrbStack 以应用配置..."
echo "提示: 您可能需要在弹出的对话框中输入管理员密码"

# 尝试重启（可能需要 sudo）
if sudo orbctl restart 2>/dev/null; then
    echo "✓ OrbStack 已重启"
else
    echo ""
    echo "⚠️  需要手动重启 OrbStack"
    echo "请执行以下操作："
    echo "1. 打开 OrbStack 应用"
    echo "2. 点击左上角的 OrbStack 菜单"
    echo "3. 选择 'Restart OrbStack'"
fi

# 等待 OrbStack 重启完成
sleep 5

# 验证挂载是否生效
echo ""
echo "验证挂载状态..."
if docker ps | grep -q "openclaw-gateway"; then
    echo "✓ Docker 容器正在运行"
    
    # 检查容器内的挂载
    if docker exec openclaws-openclaw-gateway-1 ls /home/node/workGroup > /dev/null 2>&1; then
        echo "✓ workGroup 挂载成功！"
        echo ""
        echo "挂载信息："
        echo "  宿主机路径: $WORKGROUP_HOST"
        echo "  容器内路径: $WORKGROUP_CONTAINER"
        echo ""
        echo "容器内的项目列表："
        docker exec openclaws-openclaw-gateway-1 ls /home/node/workGroup | head -10
    else
        echo "⚠️  挂载可能未生效，请手动验证"
    fi
else
    echo "⚠️  Docker 容器未运行"
fi

echo ""
echo "=== 配置完成 ==="
echo ""
echo "如果挂载未生效，请："
echo "1. 打开 OrbStack 应用"
echo "2. 找到 openclaws-openclaw-gateway-1 容器"
echo "3. Settings → Volumes → Add Mount"
echo "4. Source: $WORKGROUP_HOST"
echo "5. Target: $WORKGROUP_CONTAINER"
echo "6. 重启容器"

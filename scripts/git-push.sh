#!/bin/bash

# Git 推送脚本
# 在有交互权限的环境中运行此脚本来推送到 GitHub

set -e

echo "=== OpenClaw Git 推送脚本 ==="
echo ""
echo "仓库: https://github.com/zhou0928/openClaw.git"
echo "分支: main"
echo ""

# 检查是否有待推送的提交
PUSH_COUNT=$(git rev-list --count origin/main..main 2>/dev/null || echo "unknown")

if [ "$PUSH_COUNT" = "0" ]; then
    echo "✓ 没有待推送的提交，已是最新的"
    exit 0
elif [ "$PUSH_COUNT" = "unknown" ]; then
    echo "正在推送本地提交..."
else
    echo "有待推送的提交: $PUSH_COUNT 个"
fi

echo ""
echo "正在推送到 GitHub..."
echo "请在弹出的对话框中输入 GitHub 用户名和密码（或 Personal Access Token）"
echo ""

# 推送代码
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 推送成功！"
    echo ""
    echo "你可以在以下地址查看你的仓库："
    echo "https://github.com/zhou0928/openClaw"
else
    echo ""
    echo "✗ 推送失败"
    echo ""
    echo "请确保："
    echo "1. GitHub 用户名: zhou0928"
    echo "2. 密码: 你的 GitHub 密码或 Personal Access Token"
    echo ""
    echo "如果使用 2FA，需要创建 Personal Access Token:"
    echo "https://github.com/settings/tokens"
    exit 1
fi

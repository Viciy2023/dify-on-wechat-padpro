#!/bin/bash
# ============================================================
# deploy-to-hf.sh - 快速部署到 HuggingFace Spaces
# ============================================================

set -e

echo "=========================================="
echo "OpenClaw HuggingFace Spaces 部署脚本"
echo "=========================================="
echo ""

# 检查是否在正确的目录
if [ ! -f "Dockerfile-hf" ]; then
    echo "错误：请在 huggingface-new 目录下运行此脚本"
    exit 1
fi

# 检查 Docker Hub 用户名
if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "请输入你的 Docker Hub 用户名："
    read DOCKERHUB_USERNAME
    export DOCKERHUB_USERNAME
fi

echo "Docker Hub 用户名: $DOCKERHUB_USERNAME"
echo ""

# 步骤 1：更新 Dockerfile-hf 中的镜像名称
echo "步骤 1/4: 更新 Dockerfile-hf 中的镜像名称..."
sed -i.bak "s|your-dockerhub-username|$DOCKERHUB_USERNAME|g" Dockerfile-hf
echo "✅ 完成"
echo ""

# 步骤 2：检查预构建镜像是否存在
echo "步骤 2/4: 检查预构建镜像..."
if docker pull "$DOCKERHUB_USERNAME/openclaw-clawmate:latest" 2>/dev/null; then
    echo "✅ 预构建镜像已存在"
else
    echo "⚠️  预构建镜像不存在"
    echo "请先运行 GitHub Actions 构建镜像，或者使用原始 Dockerfile-supabase"
    echo ""
    echo "GitHub Actions 地址："
    echo "https://github.com/Viciy2023/openclaw/actions"
    exit 1
fi
echo ""

# 步骤 3：测试本地构建
echo "步骤 3/4: 测试本地构建..."
echo "是否要测试本地构建？(y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    docker build -f Dockerfile-hf -t openclaw-hf-test .
    echo "✅ 本地构建成功"
else
    echo "⏭️  跳过本地测试"
fi
echo ""

# 步骤 4：部署提示
echo "步骤 4/4: 部署到 HuggingFace Spaces"
echo ""
echo "请按以下步骤操作："
echo ""
echo "1. 确保以下文件已上传到 Supabase:"
echo "   - .env"
echo "   - openclaw.json"
echo "   - patches/clawmate/*.ts"
echo "   - characters/maggie/*"
echo "   - AGENTS.md, TOOLS.md 等"
echo ""
echo "2. 将以下文件推送到 HF Spaces:"
echo "   - Dockerfile-hf (重命名为 Dockerfile)"
echo "   - entrypoint.sh-supabase (重命名为 entrypoint.sh)"
echo ""
echo "3. 在 HF Spaces 设置中配置 Secrets:"
echo "   - SUPABASE_ANON_KEY"
echo "   - DEPLOY_FILES_BASE_URL"
echo ""
echo "4. 触发 HF Spaces 重新构建"
echo ""
echo "=========================================="
echo "部署准备完成！"
echo "=========================================="

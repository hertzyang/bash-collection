#!/usr/bin/env bash
set -euo pipefail

# ===== 配置 =====
DOCKERFILE_URL="https://raw.githubusercontent.com/hertzyang/bash-collection/refs/heads/master/rsshub-lambda-dockerfile"
IMAGE_NAME="${1:-rsshub-lambda}"
TAG="latest"

# ===== 获取 AWS 信息（兼容 CloudShell / 本地 / EC2）=====
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null || true)}}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"

# ===== fallback =====
if [ -z "$REGION" ]; then
  echo "⚠️ 未检测到 AWS region，默认使用 us-east-1"
  REGION="us-east-1"
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "❌ AWS 凭证无效或未登录"
  exit 1
fi

echo "📍 Region: $REGION"
echo "👤 Account: $ACCOUNT_ID"

ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME"

# ===== 创建 ECR =====
echo "📦 检查/创建 ECR..."
if aws ecr describe-repositories --repository-names "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "✔ ECR 已存在"
else
  aws ecr create-repository --repository-name "$IMAGE_NAME" >/dev/null
  echo "✔ 已创建 ECR"
fi

# ===== 登录 ECR =====
echo "🔐 登录 ECR..."
aws ecr get-login-password --region "$REGION" \
| docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# ===== build =====
echo "🐳 构建镜像（可能需要几分钟）..."
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_URL" .

# ===== tag =====
docker tag "$IMAGE_NAME:$TAG" "$ECR_URI:$TAG"

# ===== push =====
echo "🚀 推送到 ECR..."
docker push "$ECR_URI:$TAG"

echo ""
echo "✅ 完成！"
echo "📦 镜像地址："
echo "$ECR_URI:$TAG"

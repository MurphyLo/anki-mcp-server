#!/bin/bash

# 发布脚本 - Anki MCP Server
set -e

echo "🚀 准备发布 Anki MCP Server..."

# 检查是否已登录npm
echo "📝 检查npm登录状态..."
if ! npm whoami > /dev/null 2>&1; then
    echo "❌ 请先登录npm: npm login"
    exit 1
fi

echo "✅ 已登录为: $(npm whoami)"

# 检查是否有未提交的更改
if ! git diff --quiet; then
    echo "❌ 有未提交的更改，请先提交代码"
    exit 1
fi

# 安装依赖
echo "📦 安装依赖..."
npm install

# 运行测试
echo "🧪 运行测试..."
npm test

# 构建项目
echo "🔨 构建项目..."
npm run build

# 检查构建结果
if [ ! -d "dist" ]; then
    echo "❌ 构建失败，dist目录不存在"
    exit 1
fi

# 生成包预览
echo "📋 生成包预览..."
npm pack --dry-run

# 确认发布
echo "❓ 确认发布包到npm? (y/N)"
read -r confirm
if [[ $confirm != [yY] ]]; then
    echo "❌ 取消发布"
    exit 1
fi

# 发布包
echo "🚀 发布到npm..."
npm publish

echo "✅ 发布成功！"
echo "📄 查看包信息: https://www.npmjs.com/package/$(node -p "require('./package.json').name")"

# 推送标签到git
VERSION=$(node -p "require('./package.json').version")
# $VERSION = node -p "require('./package.json').version"

echo "🏷️  创建git标签 v$VERSION..."
git tag "v$VERSION"
git push origin "v$VERSION"

echo "🎉 发布完成！"

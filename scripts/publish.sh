#!/usr/bin/env bash
set -euo pipefail

echo "==================== NPM 一键发版脚本 ===================="
echo ""

# 1. 切换 npm 官方源
echo "1. 切换到 npm 官方源..."
npm config set registry https://registry.npmjs.org/

# 2. 检查是否登录
echo "2. 检查 npm 登录状态..."
if ! npm whoami >/dev/null 2>&1; then
  echo "未登录，正在执行 npm login..."
  npm login
fi

# 3. 检查 Git 工作区
echo "3. 检查 Git 工作区是否干净..."
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ 发现未提交的更改，请先提交或暂存后再发布。"
  exit 1
fi

currentBranch=$(git rev-parse --abbrev-ref HEAD)
echo "当前分支：${currentBranch}"

# 4. 代码检查（可根据需要开启）
echo "4. 代码检查..."
# npm run lint
# npm test

# 5. 预发布模拟（dry-run）
echo "5. 执行预发布模拟检查..."
npm publish --dry-run

echo "✅ 预发布检查通过"
echo ""

# 6. 选择版本升级
echo "请选择版本升级类型："
echo "1. patch  小修复（1.0.0 → 1.0.1）"
echo "2. minor  新功能（1.0.0 → 1.1.0）"
echo "3. major  大版本不兼容（1.0.0 → 2.0.0）"
read -p "输入序号 1/2/3: " verType

case $verType in
  1) npm version patch --no-git-tag-version ;;
  2) npm version minor --no-git-tag-version ;;
  3) npm version major --no-git-tag-version ;;
  *) echo "输入错误，退出"; exit 1 ;;
esac

newVersion=$(node -p "require('./package.json').version")
echo "已升级版本为 ${newVersion}"

# 7. Git 提交 + Tag
echo "6. 创建 Git 提交和 tag..."
git add package.json
git commit -m "chore(release): v${newVersion}"
git tag "v${newVersion}"

echo "7. 开始正式发布到 npm..."
npm publish

echo "✅ NPM 发布完成，开始推送 Git..."

git push origin "${currentBranch}"
git push origin "v${newVersion}"

echo "✅ 发布及 Git 推送完成！"

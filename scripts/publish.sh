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

# 4. 获取本地和远程版本
echo "4. 获取本地和远程版本..."
localVersion=$(node -p "require('./package.json').version")
echo "本地版本：${localVersion}"

remoteVersion=$(npm view image-to-sections version 2>/dev/null || echo "")
if [ -z "$remoteVersion" ]; then
  echo "⚠️  无法获取远程版本（可能首次发布）"
  remoteVersion="0.0.0"
fi
echo "远程版本：${remoteVersion}"

# 5. 比较版本
echo ""
echo "5. 版本检查..."

if [ "${localVersion}" = "${remoteVersion}" ]; then
  echo "⚠️  本地版本 ${localVersion} 已存在于远程，需要升级版本"
  echo ""
  echo "请选择版本升级类型："
  echo "1. patch  小修复（${localVersion} → 下一个 patch）"
  echo "2. minor  新功能（${localVersion} → 下一个 minor）"
  echo "3. major  大版本不兼容（${localVersion} → 下一个 major）"
  read -p "输入序号 1/2/3: " verType

  case $verType in
    1) npm version patch --no-git-tag-version ;;
    2) npm version minor --no-git-tag-version ;;
    3) npm version major --no-git-tag-version ;;
    *) echo "输入错误，退出"; exit 1 ;;
  esac

  newVersion=$(node -p "require('./package.json').version")
  echo "✅ 已升级版本为 ${newVersion}"
elif [ "$(printf '%s\n' "$remoteVersion" "$localVersion" | sort -V | head -n1)" = "$remoteVersion" ]; then
  echo "✅ 本地版本 ${localVersion} 高于远程版本 ${remoteVersion}"
  read -p "是否要发布当前版本 ${localVersion}？(y/n): " publishCurrent

  if [ "$publishCurrent" = "y" ] || [ "$publishCurrent" = "Y" ]; then
    newVersion="${localVersion}"
    echo "✅ 将发布当前版本 ${newVersion}"
  else
    echo ""
    echo "请选择升级基准："
    echo "1. 按照当前版本号升级（基于 ${localVersion}）"
    echo "2. 按照远程版本号升级（基于 ${remoteVersion}）"
    read -p "输入序号 1/2: " baseChoice

    case $baseChoice in
      1) baseVersion="${localVersion}" ;;
      2) baseVersion="${remoteVersion}" ;;
      *) echo "输入错误，退出"; exit 1 ;;
    esac

    echo ""
    echo "请选择版本升级类型（基于 ${baseVersion}）："
    echo "1. patch  小修复（${baseVersion} → 下一个 patch）"
    echo "2. minor  新功能（${baseVersion} → 下一个 minor）"
    echo "3. major  大版本不兼容（${baseVersion} → 下一个 major）"
    read -p "输入序号 1/2/3: " verType

    # 临时设置版本为基准版本，然后升级
    npm version "${baseVersion}" --no-git-tag-version >/dev/null 2>&1

    case $verType in
      1) npm version patch --no-git-tag-version ;;
      2) npm version minor --no-git-tag-version ;;
      3) npm version major --no-git-tag-version ;;
      *) echo "输入错误，退出"; exit 1 ;;
    esac

    newVersion=$(node -p "require('./package.json').version")
    echo "✅ 已升级版本为 ${newVersion}"
  fi
else
  echo "❌ 本地版本 ${localVersion} 低于远程版本 ${remoteVersion}，无法发布"
  exit 1
fi

echo ""

# 6. 代码检查（可根据需要开启）
echo "6. 代码检查..."
# npm run lint
# npm test

# 7. 预发布模拟（dry-run）
echo "7. 执行预发布模拟检查..."
npm publish --dry-run

echo "✅ 预发布检查通过"
echo ""

# 8. Git 提交 + Tag
echo "8. 创建 Git 提交和 tag..."

# 检查 package.json 是否有变化
if git diff --quiet package.json; then
  echo "⚠️  package.json 无变化，跳过 git 提交"
else
  git add package.json
  git commit -m "chore(release): v${newVersion}"
fi

# 检查 tag 是否已存在
if git rev-parse "v${newVersion}" >/dev/null 2>&1; then
  echo "⚠️  标签 v${newVersion} 已存在，跳过创建"
else
  git tag "v${newVersion}"
fi

echo "9. 开始正式发布到 npm..."
npm publish

echo "✅ NPM 发布完成，开始推送 Git..."

git push origin "${currentBranch}"
git push origin "v${newVersion}"

echo "✅ 发布及 Git 推送完成！版本 v${newVersion} 已成功发布"

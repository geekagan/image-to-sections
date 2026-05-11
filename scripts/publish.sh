#!/usr/bin/env bash
set -euo pipefail

# ==================== 配置 ====================
DRY_RUN=false
PACKAGE_NAME="image-to-sections"
TIMEOUT=300  # 5分钟超时

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# ==================== 辅助函数 ====================
log_info() { echo "ℹ️  $1"; }
log_success() { echo "✅ $1"; }
log_warn() { echo "⚠️  $1"; }
log_error() { echo "❌ $1"; }

# 执行带超时的命令（macOS 兼容）
run_with_timeout() {
  local timeout=$1
  shift
  
  # 检测系统类型
  if command -v timeout >/dev/null 2>&1; then
    # Linux 系统
    timeout "$timeout" "$@" || {
      log_error "命令超时（${timeout}s）: $*"
      exit 1
    }
  elif command -v gtimeout >/dev/null 2>&1; then
    # macOS with GNU coreutils
    gtimeout "$timeout" "$@" || {
      log_error "命令超时（${timeout}s）: $*"
      exit 1
    }
  else
    # macOS fallback（使用 perl 实现超时）
    log_warn "系统不支持 timeout 命令，使用无超时模式（可能卡住）"
    "$@" || {
      log_error "命令执行失败: $*"
      exit 1
    }
  fi
}

echo "==================== NPM 一键发版脚本 ===================="
echo ""
if [ "$DRY_RUN" = true ]; then
  log_warn "【模拟模式】不会执行真实发布和 Git 推送"
  echo ""
fi

# ==================== 步骤 1：切换 npm 源 ====================
echo "1. 切换到 npm 官方源..."
npm config set registry https://registry.npmjs.org/

# ==================== 步骤 2：检查登录 ====================
echo "2. 检查 npm 登录状态..."
if ! npm whoami >/dev/null 2>&1; then
  log_warn "未登录，正在执行 npm login..."
  npm login
fi

# ==================== 步骤 3：检查 Git 工作区 ====================
echo "3. 检查 Git 工作区是否干净..."
if [ -n "$(git status --porcelain)" ]; then
  log_error "发现未提交的更改，请先提交或暂存后再发布"
  exit 1
fi

currentBranch=$(git rev-parse --abbrev-ref HEAD)
log_info "当前分支：${currentBranch}"

# ==================== 步骤 4：获取本地和远程版本 ====================
echo "4. 获取版本信息..."
localVersion=$(node -p "require('./package.json').version")
remoteVersion=$(npm view "$PACKAGE_NAME" version 2>/dev/null || echo "")

if [ -z "$remoteVersion" ]; then
  log_warn "无法获取远程版本（可能首次发布）"
  remoteVersion="0.0.0"
fi

echo "  本地版本：${localVersion}"
echo "  远程版本：${remoteVersion}"

# ==================== 步骤 5：版本检查和升级 ====================
echo ""
echo "5. 版本检查..."

if [ "${localVersion}" = "${remoteVersion}" ]; then
  log_warn "本地版本 ${localVersion} 已存在于远程，需要升级版本"
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
    *) log_error "输入错误"; exit 1 ;;
  esac

  newVersion=$(node -p "require('./package.json').version")
  log_success "已升级版本为 ${newVersion}"

elif [ "$(printf '%s\n' "$remoteVersion" "$localVersion" | sort -V | head -n1)" = "$remoteVersion" ]; then
  log_success "本地版本 ${localVersion} 高于远程版本 ${remoteVersion}"
  read -p "是否要发布当前版本 ${localVersion}？(y/n): " publishCurrent

  if [ "$publishCurrent" = "y" ] || [ "$publishCurrent" = "Y" ]; then
    newVersion="${localVersion}"
    log_success "将发布当前版本 ${newVersion}"
  else
    echo ""
    echo "请选择升级基准："
    echo "1. 按照当前版本号升级（基于 ${localVersion}）"
    echo "2. 按照远程版本号升级（基于 ${remoteVersion}）"
    read -p "输入序号 1/2: " baseChoice

    case $baseChoice in
      1) baseVersion="${localVersion}" ;;
      2) baseVersion="${remoteVersion}" ;;
      *) log_error "输入错误"; exit 1 ;;
    esac

    echo ""
    echo "请选择版本升级类型（基于 ${baseVersion}）："
    echo "1. patch  小修复（${baseVersion} → 下一个 patch）"
    echo "2. minor  新功能（${baseVersion} → 下一个 minor）"
    echo "3. major  大版本不兼容（${baseVersion} → 下一个 major）"
    read -p "输入序号 1/2/3: " verType

    npm version "${baseVersion}" --no-git-tag-version >/dev/null 2>&1

    case $verType in
      1) npm version patch --no-git-tag-version ;;
      2) npm version minor --no-git-tag-version ;;
      3) npm version major --no-git-tag-version ;;
      *) log_error "输入错误"; exit 1 ;;
    esac

    newVersion=$(node -p "require('./package.json').version")
    log_success "已升级版本为 ${newVersion}"
  fi
else
  log_error "本地版本 ${localVersion} 低于远程版本 ${remoteVersion}，无法发布"
  exit 1
fi

echo ""

# ==================== 步骤 6：代码检查 ====================
echo "6. 代码检查..."
# npm run lint
# npm test
log_info "跳过（可在脚本中取消注释开启）"

# ==================== 步骤 7：预发布模拟 ====================
echo "7. 执行预发布模拟检查..."
run_with_timeout "$TIMEOUT" npm publish --dry-run
log_success "预发布检查通过"
echo ""

# ==================== 步骤 8：发布前确认 ====================
echo "8. 发布前确认"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  本地版本：${localVersion}"
echo "  远程版本：${remoteVersion}"
echo "  将发布版本：${newVersion}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DRY_RUN" = true ]; then
  log_warn "【模拟模式】将跳过真实发布"
else
  read -p "确认发布版本 v${newVersion}？(y/n): " confirmPublish
  if [ "$confirmPublish" != "y" ] && [ "$confirmPublish" != "Y" ]; then
    log_warn "用户取消发布"
    exit 0
  fi
fi

echo ""

# ==================== 步骤 9：再次验证登录 ====================
if [ "$DRY_RUN" = false ]; then
  echo "9. 再次验证 npm 登录状态..."
  if ! npm whoami >/dev/null 2>&1; then
    log_error "登录状态失效，请重新登录"
    npm login
  fi
  log_success "登录验证通过"
  echo ""
fi

# ==================== 步骤 10：Git 提交 + Tag ====================
echo "10. 创建 Git 提交和 tag..."

if git diff --quiet package.json; then
  log_warn "package.json 无变化，跳过 git 提交"
else
  git add package.json
  
  # 检查并处理 lock 文件
  if [ -f "package-lock.json" ]; then
    git add package-lock.json
    log_info "已添加 package-lock.json"
  fi
  if [ -f "yarn.lock" ]; then
    git add yarn.lock
    log_info "已添加 yarn.lock"
  fi
  
  git commit -m "chore(release): v${newVersion}"
  log_success "Git 提交完成"
fi

# 检查 tag 是否已存在
if git rev-parse "v${newVersion}" >/dev/null 2>&1; then
  log_warn "标签 v${newVersion} 已存在，跳过创建"
else
  git tag "v${newVersion}"
  log_success "Git tag 创建完成"
fi

echo ""

# ==================== 步骤 11：NPM 发布 ====================
echo "11. 开始发布到 npm..."

if [ "$DRY_RUN" = true ]; then
  log_warn "【模拟模式】跳过真实发布"
else
  if run_with_timeout "$TIMEOUT" npm publish; then
    log_success "NPM 发布成功"
  else
    log_error "NPM 发布失败"
    exit 1
  fi
fi

echo ""

# ==================== 步骤 12：Git 推送 ====================
echo "12. 推送到 Git 仓库..."

if [ "$DRY_RUN" = true ]; then
  log_warn "【模拟模式】跳过 Git 推送"
else
  if run_with_timeout "$TIMEOUT" git push origin "${currentBranch}" --follow-tags; then
    log_success "Git 推送完成"
  else
    log_error "Git 推送失败"
    exit 1
  fi
fi

echo ""
echo "==================== 发布完成 ===================="
echo ""
echo "📦 版本号：v${newVersion}"
echo "🌐 npm 包：https://www.npmjs.com/package/${PACKAGE_NAME}"
echo "🔗 GitHub：https://github.com/geekagan/${PACKAGE_NAME}/releases/tag/v${newVersion}"
echo ""

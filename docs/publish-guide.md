# publish.sh 使用说明

本文件说明 `scripts/publish.sh` 的使用方式与流程，该脚本用于对 `image-to-sections` 包进行一键发布。

## 1. 文件位置

项目根目录下的脚本文件：

* `scripts/publish.sh`

本说明文件：

* `scripts/PUBLISH.md`

## 2. 脚本作用

`publish.sh` 会执行以下发布流程：

01. 切换 npm 官方 registry
02. 检查 npm 登录状态
03. 检查 Git 工作区是否干净
04. 获取本地 `package.json` 版本与远程 npm 版本
05. 版本检查与升级选择
06. 可选代码检查（当前默认注释）
07. 执行 `npm publish --dry-run` 预发布模拟
08. 发布前版本确认
09. 再次验证 npm 登录
10. Git 提交与 tag
11. 正式 `npm publish`
12. Git 推送分支和 tag

## 3. 基本使用

在项目根目录执行：

```bash
git checkout master
bash ./scripts/publish.sh
```

如果你想先进行模拟发布，可以使用：

```bash
bash ./scripts/publish.sh --dry-run
```

## 4. 脚本行为说明

### 4.1 登录检查

脚本会运行 `npm whoami` 判断 npm 是否已登录。若未登录，会自动进入 `npm login` 。

### 4.2 Git 工作区检查

脚本要求当前工作区没有未提交更改。若出现修改、暂存或者未跟踪文件，会中断执行。

### 4.3 版本比较与升级策略

脚本会读取当前项目的本地版本，并从 npm 远程查询当前发布版本：

* 若本地版本等于远程版本，脚本会提示你选择 `patch/minor/major` 版本升级。
* 若本地版本大于远程版本，脚本会询问是否直接发布当前版本：
  + 选择 `y`：直接发布当前本地版本
  + 选择 `n`：进入版本基准选择，并继续升级
* 若本地版本小于远程版本，脚本会直接报错并退出。

### 4.4 预发布模拟

完成版本确认后，脚本会执行：

```bash
npm publish --dry-run
```

用于检查发布包是否可用。

### 4.5 发布前确认

脚本会展示：

* 本地版本
* 远程版本
* 将要发布的版本

并要求你确认是否继续发布。

### 4.6 Git 提交与 tag

如果 `package.json` 有变化，会自动将 `package.json` 提交到 Git，并自动创建 `v<version>` tag。

脚本还会检测并一起提交：

* `package-lock.json`
* `yarn.lock`

如果这两个文件存在。

### 4.7 发布后推送

发布完成后，脚本会推送当前分支和 tag：

```bash
git push origin <branch> --follow-tags
```

## 5. 交互提示说明

在版本检查阶段，可能出现以下交互：

* `输入序号 1/2/3:`：选择 patch/minor/major 升级
* `是否要发布当前版本 ...？(y/n):`：直接发布当前版本或进入升级逻辑
* `输入序号 1/2:`：选择以本地版本还是远程版本为基准升级
* `确认发布版本 v...？(y/n):`：确认是否继续正式发布

## 6. 浏览器认证处理

如果 npm 发布触发 Web 认证流程，脚本会检测认证地址，并自动尝试打开默认浏览器。

如果自动打开失败，请手动复制提示中的认证链接到浏览器完成登录。

## 7. 备注

* 脚本默认使用 `npm registry https://registry.npmjs.org/`。
* 你可以在脚本内打开 `npm run lint` / `npm test` 以加入发布前检查。
* 当前脚本已支持 macOS 与 Linux 的超时控制，如果本地没有 `timeout` 命令，会退回为无超时模式。

## 8. 常见问题

### Q: 我只想模拟，不想真实发布

A: 使用 `bash ./scripts/publish.sh --dry-run` 。

### Q: 我想发布当前版本，但远程版本比我旧

A: 选择 `y` 发布当前版本即可。

### Q: npm 要求浏览器认证怎么办？

A: 脚本会尝试自动打开认证地址，若未打开请手动访问提示链接。

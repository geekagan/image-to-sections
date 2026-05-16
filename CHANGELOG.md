# Changelog

All notable changes to this project will be documented in this file.

## [0.1.13] - 2025-05-08

### Fixed
- 修复根 `index.js` 中 `canvasToImageFile` 漏导出问题
- 修复根 `index.js` 中 `export default` 引用未声明变量的 bug

### Changed
- 项目目录结构调整：`demo/` → `examples/`，`material/` → `assets/`
- `scripts/PUBLISH.md` 迁移至 `docs/publish-guide.md`
- `.npmignore` 补充排除 `scripts/`、`docs/`、`assets/`、`examples/` 等开发文件

## [0.1.12] - 2025-04-01

### Added
- 新增 `publish.sh` 一键发版脚本

## [0.1.0] - 2024-01-01

### Added
- 初始发布
- `getBigImageSectionFiles`：大图片切片，返回 File 数组
- `imageFileToThumbFile`：生成缩略图 File
- `imageToCanvas`：图片转 Canvas
- `getImageCanvasSections` / `getImageCanvasSectionsH` / `getImageCanvasSectionsV`：Canvas 切片
- `canvasToBlob`：Canvas 转 Blob
- `canvasToImageFile`：Canvas 转 ImageFile

我给你整理成**清爽、专业、赏心悦目、可直接用于 README** 的排版格式，结构清晰、层级分明、阅读体验极佳👇

# image-to-sections

一个轻量、易用的图片处理工具库，支持图片切片、缩略图、Canvas 转换、文件导出等功能。

---

## 主要功能

* ✅ 大图片切片（**横切 / 竖切**）
* ✅ 生成图片**缩略图**
* ✅ 图片转 Canvas
* ✅ 获取 Canvas 切片数组（横/纵）
* ✅ Canvas 转 Blob / ImageFile

---

## 安装

```bash
npm install image-to-sections --save
```

## 使用方式

### 整体引入

```javascript
import imageToSection from 'image-to-sections'
```

### 按需引入

```javascript
import {
    getBigImageSectionFiles,
    imageFileToThumbFile,
    imageToCanvas,
    getImageCanvasSections,
    getImageCanvasSectionsH,
    getImageCanvasSectionsV,
    canvasToBlob,
    canvasToImageFile
} from 'image-to-sections'
```

---

# API 方法说明

## 1. getBigImageSectionFiles()

**获取大图片切片后的 File 数组**

```javascript
/**
 * @description 获取大图片 File 的切片后的 Files: [file, file, ...]
 * @param {File} imageFile - 图片 File 对象
 * @param {Object} options - 配置项
 *    sectionWidth    切片宽度，默认 750
 *    sectionHeight   切片高度，默认 100
 *    cutDirection    切片方向：horizontal | vertical（默认 horizontal）
 *    allowZoom       是否允许缩放，默认 false
 *
 * @introduction
 * 1. cutDirection=horizontal 时，仅 sectionHeight 生效
 * 2. cutDirection=vertical 时，仅 sectionWidth 生效
 * 3. allowZoom=true 时，宽高同时生效
 *
 * @return {File[]} 切片文件列表
 */
```

---

## 2. imageFileToThumbFile()

**生成图片缩略图 File**

```javascript
/**
 * @description 获取 image file 的缩略图文件
 * @param {File} imageFile - 图片 File 对象
 * @param {Object} options - 配置项
 *    thumbWidth   缩略图宽度
 *    thumbHeight  缩略图高度
 *
 * @introduction
 * 1. 同时传宽高 → 以宽度为基准等比缩放
 * 2. 只传宽 → 等比缩放
 * 3. 只传高 → 等比缩放
 * 4. 都不传 → 使用原图尺寸
 *
 * @return {File} 缩略图 File
 */
```

---

## 3. imageToCanvas()

**图片转 Canvas DOM 对象**

```javascript
/**
 * @description 图片 img 转为 canvas
 * @param {Image} loadedImage - 已加载完成的图片对象
 * @param {Object} options - 配置项
 *    canvWidth     canvas 宽度，默认 0
 *    canvHeight    canvas 高度，默认 0
 *    distorted     是否允许失真，默认 false
 *
 * @return {HTMLCanvasElement} canvas
 */
```

---

## 4. getImageCanvasSections()

**获取图片的 Canvas 切片数组**

```javascript
/**
 * @description 获取图片的 canvas 切片数组
 * @param {Image} loadedImage - 已加载图片对象
 * @param {Object} options - 配置项
 *    sectionWidth    切片宽度，默认 750
 *    sectionHeight   切片高度，默认 100
 *    cutDirection    horizontal | vertical（默认 horizontal）
 *
 * @introduction
 * 1. horizontal → 仅高度生效
 * 2. vertical   → 仅宽度生效
 *
 * @return {HTMLCanvasElement[]} canvas 切片列表
 */
```

---

## 5. getImageCanvasSectionsH()

**获取图片**横切**后的 Canvas 切片数组**

```javascript
/**
 * @description 图片横切后的 canvas 切片数组
 * @param {Image} loadedImage - 已加载图片对象
 * @param {Number} canvasHeight - 切片高度
 *
 * @return {HTMLCanvasElement[]}
 */
```

---

## 6. getImageCanvasSectionsV()

**获取图片**竖切**后的 Canvas 切片数组**

```javascript
/**
 * @description 图片竖切后的 canvas 切片数组
 * @param {Image} loadedImage - 已加载图片对象
 * @param {Number} canvasWidth - 切片宽度
 *
 * @return {HTMLCanvasElement[]}
 */
```

---

## 7. canvasToBlob()

**Canvas 转 Blob 二进制数据**

```javascript
/**
 * @description canvas 转 blob
 * @param {HTMLCanvasElement} canvasObj
 * @param {String} transType - 图片类型：image/jpg | image/jpeg | image/png（默认 png）
 * @param {Number} transQuality - 图片质量 0~1，默认 1
 *
 * @return {Promise<Blob>}
 */
```

---

## 8. canvasToImageFile()

**Canvas 转 ImageFile 对象**

```javascript
/**
 * @description canvas 转 image file
 * @param {HTMLCanvasElement} canvasObj
 * @param {Object} options - 配置项
 *    transType      图片类型，默认 image/png
 *    transQuality   图片质量 0~1，默认 1
 *    imageName      文件名，默认 image-file
 *    suffix         文件后缀，默认 png
 *    lastModified   最后修改时间，默认 Date.now()
 *
 * @return {Promise<File>}
 */
```

---

如果你需要，我还能帮你生成：
✅ **GitHub README 美化版（带徽章、目录、预览）**
✅ **中文/英文双版本文档**
✅ **可直接发布 npm 的 README.md**

你要我直接帮你生成完整版吗？

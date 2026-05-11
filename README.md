# image\-to\-sections 🖼️

> 📖 **[English Version](README.en.md)** | 🌟 **轻量级前端图片处理库**

一个轻量、高效、易用的前端图片处理工具库，专注于图片切片、缩略图生成、Canvas 转换及文件导出，零多余依赖，适配所有现代浏览器，支持 npm 直接引入使用。

## 📋 目录

* [功能介绍](#-功能介绍)

* [功能预览](#-功能预览)

* [安装](#-安装)

* [使用方式](#-使用方式 )

* [API 详细说明](#-api-详细说明)

* [使用示例](#-使用示例)

* [浏览器兼容](#-浏览器兼容)

* [许可证](#-许可证)

## ✨ 功能介绍

专注于前端图片处理核心需求，API 简洁易懂，开箱即用，无需复杂配置，体积轻量，不增加项目冗余。

* 🖌️ 图片切片：支持横切、竖切，可配置尺寸、是否缩放，适配大图片拆分

* 🔍 缩略图生成：按比例缩放，自定义宽高，适配各类显示场景

* 🎨 Canvas 转换：图片与 Canvas 互转，支持切片、Blob/File 导出，适配绘图/上传场景

### 📸 功能预览

核心能力：大图片切片（横切/竖切）、缩略图生成、Canvas 格式转换

示例：原始图 | 横切预览 | 竖切预览

<div style="display: flex; justify-content: space-around; ">
  <img src="material/origin-image.png" alt="原始图" style="width: 30%; ">
  <img src="material/h-sliced-image.png" alt="横切预览" style="width: 30%; ">
  <img src="material/v-sliced-image.png" alt="竖切预览" style="width: 30%; ">
</div>

## 📦 安装

支持 npm、yarn 安装，按需引入可减小打包体积，适配前端工程化项目。

```bash
# npm（推荐）
npm install image-to-sections --save

# yarn
yarn add image-to-sections
    
```

## 🔧 使用方式

支持整体引入和按需引入，按需引入可减少不必要的代码打包，推荐生产环境使用。

### 整体引入

```javascript
import imageToSection from 'image-to-sections'
```

### 按需引入（推荐）

```javascript
import {
    getBigImageSectionFiles, // 大图片切片（File 输出，核心功能）
    imageFileToThumbFile, // 生成缩略图（File）
    imageToCanvas, // 图片转 Canvas
    getImageCanvasSections, // Canvas 切片数组
    getImageCanvasSectionsH, // Canvas 横切（简化版）
    getImageCanvasSectionsV, // Canvas 竖切（简化版）
    canvasToBlob, // Canvas 转 Blob（用于上传/下载）
    canvasToImageFile // Canvas 转 ImageFile（用于表单上传）
} from 'image-to-sections'
```

## 📚 API 详细说明

所有 API 均提供清晰的参数说明和使用场景，无需额外文档，直接参考以下说明即可使用。

### 1\. getBigImageSectionFiles\(imageFile, options\)

**核心功能**：将大图片 File 对象切片，返回切片后的 File 数组（最常用）。

```javascript
/**
 * @description 获取大图片 File 的切片后的 Files: [file, file, ...]
 * @param {File} imageFile - 图片 File 对象（必填）
 * @param {Object} options - 配置项（可选）
 *    sectionWidth    切片宽度，默认 750
 *    sectionHeight   切片高度，默认 100
 *    cutDirection    切片方向：'horizontal'（横切） | 'vertical'（竖切），默认 'horizontal'
 *    allowZoom       是否允许缩放，默认 false；true 时按宽高比例缩放后再切片
 *
 * @introduction
 * 1. 横切时仅 sectionHeight 生效，竖切时仅 sectionWidth 生效
 * 2. 允许缩放时，宽高同时生效，图片按比例适配后切片
 *
 * @return {File[]} 切片后的 File 数组
 */
```

### 2\. imageFileToThumbFile\(imageFile, options\)

**功能**：生成图片的缩略图 File 对象，支持等比缩放，适配预览场景。

```javascript
/**
 * @description 获取 image file 的缩略图文件
 * @param {File} imageFile - 图片 File 对象（必填）
 * @param {Object} options - 配置项（可选）
 *    thumbWidth   缩略图宽度（可选）
 *    thumbHeight  缩略图高度（可选）
 *
 * @introduction 无论传入单参数还是双参数，均自动等比缩放，避免失真
 * @return {File} 缩略图 File 对象
 */
```

### 3\. imageToCanvas\(loadedImage, options\)

**功能**：将已加载的 Image 对象转为 Canvas DOM 对象，适配绘图场景。

```javascript
/**
 * @description 图片 img 转为 canvas，并获取其 canvas dom 对象
 * @param {Image} loadedImage - 已加载完成的 Image 对象（必填，需确保图片加载完成）
 * @param {Object} options - 配置项（可选）
 *    canvWidth     canvas 宽度，默认 0（使用图片原始宽度）
 *    canvHeight    canvas 高度，默认 0（使用图片原始高度）
 *    distorted     是否允许失真，默认 false；true 时强制按指定宽高拉伸
 *
 * @return {HTMLCanvasElement} Canvas DOM 对象
 */
```

### 4\. getImageCanvasSections\(loadedImage, options\)

**功能**：获取图片的 Canvas 切片数组（不导出 File，仅返回 Canvas 对象）。

```javascript
/**
 * @description 获取图片 loadedImage 的 canvas 切片数组
 * @param {Image} loadedImage - 已加载的 image 对象（必填）
 * @param {Object} options - 配置项（可选），同 getBigImageSectionFiles
 * @returns {HTMLCanvasElement[]} Canvas 切片数组
 */
```

### 5\. getImageCanvasSectionsH\(loadedImage, canvasHeight\)

**功能**：快速获取图片横切后的 Canvas 切片数组（简化版 API）。

```javascript
/**
 * @description 图片横切后的 canvas 切片数组
 * @param {Image} loadedImage - 已加载完成的目标图片对象（必填）
 * @param {Number} canvasHeight - 每个 Canvas 切片的高度（必填）
 * @return {HTMLCanvasElement[]} 横切后的 Canvas 数组
 */
```

### 6\. getImageCanvasSectionsV\(loadedImage, canvasWidth\)

**功能**：快速获取图片竖切后的 Canvas 切片数组（简化版 API）。

```javascript
/**
 * @description 图片竖切后的 canvas 切片数组
 * @param {Image} loadedImage - 已加载完成的目标图片对象（必填）
 * @param {Number} canvasWidth - 每个 Canvas 切片的宽度（必填）
 * @return {HTMLCanvasElement[]} 竖切后的 Canvas 数组
 */
```

### 7\. canvasToBlob\(canvasObj, transType, transQuality\)

**功能**：将 Canvas 对象转为 Blob 二进制数据，用于上传或下载。

```javascript
/**
 * @description canvas 转成 blob 二进制数据
 * @param {HTMLCanvasElement} canvasObj - Canvas DOM 对象（必填）
 * @param {String} transType - 图片类型，默认 'image/png'，可选 'image/jpg'|'image/jpeg'
 * @param {Number} transQuality - 图片品质 0~1，默认 1（最高品质）
 * @returns {Promise<Blob>} 返回 Blob 数据的 Promise
 */
```

### 8\. canvasToImageFile\(canvasObj, options\)

**功能**：将 Canvas 对象转为 ImageFile 对象，可直接用于表单上传。

```javascript
/**
 * @description canvas 转 image file
 * @param {HTMLCanvasElement} canvasObj - Canvas DOM 对象（必填）
 * @param {Object} options - 配置项（可选）
 *    transType      图片格式，默认 'image/png'
 *    transQuality   图片质量 0~1，默认 1
 *    imageName      文件名，默认 'image-file'
 *    suffix         文件后缀，默认 'png'
 *    lastModified   最后修改时间，默认 Date.now()
 * @returns {Promise<File>} 返回 ImageFile 对象的 Promise
 */
```

## 💡 使用示例

以下是最常用场景的完整示例，可直接复制到项目中使用。

### 示例 1：大图片横切（核心场景）

```javascript
// 1. 获取 input 上传的图片 File 对象
const input = document.querySelector('input[type="file"]');
input.addEventListener('change', async (e) => {
    const imageFile = e.target.files[0];
    if (!imageFile) return;

    // 2. 配置切片参数（横切，切片高度 200px，允许缩放）
    const options = {
        cutDirection: 'horizontal',
        sectionHeight: 200,
        allowZoom: true
    };

    // 3. 执行切片，获取切片 File 数组
    const sectionFiles = await getBigImageSectionFiles(imageFile, options);

    // 4. 处理切片（示例：打印切片数量、上传切片）
    console.log('切片完成，共', sectionFiles.length, '个切片');
    sectionFiles.forEach((file, index) => {
        console.log(`切片 ${index + 1}`, file);
        // 上传示例：
        // const formData = new FormData(); 
        // formData.append(`section${index}`, file);
    });
});
```

### 示例 2：生成图片缩略图

```javascript
// 上传图片并生成缩略图（宽度 200px，等比缩放）
const input = document.querySelector('input[type="file"]');
input.addEventListener('change', async (e) => {
    const imageFile = e.target.files[0];
    if (!imageFile) return;

    // 配置缩略图宽度
    const thumbFile = await imageFileToThumbFile(imageFile, {
        thumbWidth: 200
    });

    // 预览缩略图
    const img = document.createElement('img');
    img.src = URL.createObjectURL(thumbFile);
    img.style.width = '200px';
    document.body.appendChild(img);
});
```

### 示例 3：Canvas 转 ImageFile 并上传

```javascript
// 1. 先将图片转为 Canvas（替换为自己的图片地址）
const img = new Image();
img.src = 'https://via.placeholder.com/500x300?text=Sample+Image'; // 稳定占位图，可直接使用
img.onload = async () => {
    const canvas = imageToCanvas(img);

    // 2. Canvas 转 ImageFile
    const imageFile = await canvasToImageFile(canvas, {
        imageName: 'my-image',
        transType: 'image/jpeg',
        transQuality: 0.8
    });

    // 3. 上传文件
    const formData = new FormData();
    formData.append('image', imageFile);
    fetch('/api/upload', {
        method: 'POST',
        body: formData
    });
};
```

## 🌐 浏览器兼容

支持所有现代浏览器，IE 浏览器需兼容 Canvas 和 File API（建议使用 polyfill）。

* Chrome ≥ 58

* Firefox ≥ 54

* Safari ≥ 11

* Edge ≥ 16

* IE ≥ 11（需 polyfill）

## 📄 许可证

本项目基于[MIT 许可证](https://opensource.org/licenses/MIT)开源，可自由用于个人和商业项目，无需额外授权。

MIT 许可证核心条款：允许免费使用、复制、修改、分发本软件，需保留版权和许可声明，软件按“原样”提供，不承担任何担保责任。

Made with ❤️ \| 如需反馈或贡献代码，请访问 [GitHub 仓库](https://github.com/geekagan/image-to-sections)

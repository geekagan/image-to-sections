# Package: image-to-sections

## Description:
> 主要功能：
>
> 1. 将 大图片做成切片; 提供 横切 和 竖切 两种切片方式;    --> getBigImageSectionFiles()
>
> 其它功能：
> 
> 1. 获取图片的缩略图；                 --> imageFileToThumbFile()
> 
> 2. 获取图片的 canvas dom 对象；       --> imageToCanvas()
> 
> 3. 获取图片的 canvas 切片数组；       --> getImageCanvasSections()
>
> 4. 获取图片的 canvas 横向切片数组；   --> getImageCanvasSectionsH()
>
> 5. 获取图片的 canvas 纵向切片数组；   --> getImageCanvasSectionsV()
>
> 6. canvas 对象转为 blob 二进制数据；  --> canvasToBlob()

## Usage:
> 安装：
>
> *npm install image-to-sections --save*
>
> 整体引入：
>
> *export imageToSection from 'image-to-sections'*
>
> 按需引入：
>
> *export { getBigImageSectionFiles } from 'image-to-sections'*


## Methods Introduction:
>- getBigImageSectionFiles(imageFile, options={})
```
/**
 * @description: 获取大图片File, 的切片后的 Files: [file, file, ...]
 *
 * @param {Image} imageFile: 图片 File 对象
 *
 * @param {Object} options
 *                    sectionWidth: 切片宽度; 默认： 750
 *                    sectionHeight: 切片高度； 默认： 100
 *                    cutDirection: 描述：图片的切向； 
 *                                  可选： 'horizontal'<横切> | 'vertical'<纵切>; 
 *                                  默认： 'horizontal';
 *                    allowZoom: 是否允许缩放；可选：true | false; 默认： false
 *
 * @introduction 1. 当 cutDirection==='horizontal' 时，sectionHeight 起作用，sectionWidth 不起作用
 *               2. 当 cutDirection==='vertical' 时，sectionHeight 不起作用，sectionWidth 起作用
 *     
 * @return {Array} fileList: [File, ...]
 */
```

>- imageFileToThumbFile(imageFile, options={})
```
/**
 * @desction 获取 image file 的缩略图的 file 文件
 *
 * @param {File} imageFile: 图片 File 对象
 *
 * @param {Object} options 
 *                  thumbWidth: 缩略的宽度
 *                  thumbHeight: 缩略图的高度
 *
 * @introduction 1. 当 options.thumbWidth && options.thumbHeight 时，缩略图以 options.thumbWidth 为基准进行等比缩放
 *               2. 当 options.thumbWidth && !options.thumbHeight 时，缩略图以 options.thumbWidth 为基准进行等比缩放
 *               3. 当 !options.thumbWidth && options.thumbHeight 时，缩略图以 options.thumbHeight 为基准进行等比缩放
 *               4. 当 !options.thumbWidth && !options.thumbHeight 时, 缩略图即为当前图片的大小
 *
 * @return {File} thumbFile: 缩略图的 File 对象
 */
```

>- imageToCanvas(loadedImage, options={})
```
/**
 * @description 图片 img 转为 canvas，并获取其 canvas dom 对象
 *
 * @param {Image} loadedImage: 已加载的 image 对象
 *
 * @return {Canvas} canvas
 */
```

>- getImageCanvasSections(loadedImage, options={})
```
/**
 * @description 获取图片 loadedImage 的 canvas 切片数组
 *
 * @param {Image} loadedImage: 已加载的 image 对象
 *
 * @param {Object} options 
 *                    sectionWidth: 切片宽度; 默认： 750
 *                    sectionHeight: 切片高度； 默认： 100
 *                    cutDirection: 描述：图片的切向； 
 *                                  可选： 'horizontal'<横切> | 'vertical'<纵切> ; 
 *                                  默认： 'horizontal';
 *
 * @introduction 1. 当 cutDirection==='horizontal' 时，sectionHeight 起作用，sectionWidth 不起作用
 *              2. 当 cutDirection==='vertical' 时，sectionHeight 不起作用，sectionWidth 起作用  
 *
 * @returns {Array} canvasSections: [<canvas>, ...]
 */
```

>- getImageCanvasSectionsH(loadedImage, canvasHeight)
```
/**
 * @description 获取图片 img 的 横切后的 canvas 切片数组
 *
 * @param {Image } loadedImage 【加载完成的目标图片对象】
 *
 * @param {Number} canvasHeight 【canvas 切片的高度】
 *
 * @return {Array} canvasArray: [<canvas>, ...]
 */
```

>- getImageCanvasSectionsV(loadedImage, canvasWidth)
```
/**
 * @description 获取图片 img 的 纵切后的 canvas 切片数组
 *
 * @param {Image } loadedImage 【加载完成的目标图片对象】
 *
 * @param {Number} canvasWidth 【canvas 切片的宽度】
 *
 * @return {Array} canvasArray: [<canvas>, ...]
 */
```

>- canvasToBlob (canvasObj, transType, transQuality)
```
/**
 * @decription: canvas 转成 blob 二进制
 *
 * @param {Canvas} canvasObj 
 *
 * @param {String} transType: 要转成的文件类型，
 *                            可选：'image/jpg' | 'image/jpeg' | 'image/png'; 
 *                            默认：'image/png';
 *
 * @param {Number} transQuality: 图片品质；可选：0--1； 默认： 1
 *
 * @returns {Promise} promise
 */
```


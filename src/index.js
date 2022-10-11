/**
 * @description: 获取大图片File, 的切片后的 Files: [file, file, ...]
 * @param {Image} imgFile 
 * @param {Object} options
 *                    sectionWidth: 切片宽度; 默认： 750
 *                    sectionHeight: 切片高度； 默认： 100
 *                    cutDirection: 描述：图片的切向； 可选： 'horizontal'<横切> | 'vertical'<纵切>; 默认： 'horizontal';
 *                    allowZoom: 是否允许缩放；可选：true | false; 默认： false
 * @introduction 1. 当 cutDirection==='horizontal' 时，sectionHeight 起作用，sectionWidth 不起作用
 *              2. 当 cutDirection==='vertical' 时，sectionHeight 不起作用，sectionWidth 起作用           
 * @return [File, ...] fileList
 */
 export async function getBigImageSectionFiles (imgFile, options={}) {
  console.log('getBigImageSectionFiles imgFile ==> ', imgFile)
  // 参数 & 默认值
  options = { 
    sectionWidth: options.sectionWidth || 750, 
    sectionHeight: options.sectionHeight || 100,
    cutDirection: options.cutDirection || 'horizontal', 
    allowZoom: options.allowZoom || false
  }
  console.log('options 1 --------> ', options)
  // 把 imageFile 转为 image 实例
  const source = URL.createObjectURL(imgFile) // 参考： https://developer.mozilla.org/zh-CN/docs/Web/API/URL/createObjectURL
  const newImg = new Image()
  newImg.crossOrigin = "Anonymous"
  newImg.src = source
  // 获取加载后的 image 实例
  let loadedImg = await imageLoaded(newImg)
  // zoom image 实例
  loadedImg = zoomImageForSection(loadedImg, options)
  console.log(loadedImg.width, loadedImg.height)
  // 实例已经加载完成，不再需要 source, 释放之前已经存在的、通过调用 URL.createObjectURL() 创建的 URL 对象;
  URL.revokeObjectURL(source); 
  // 获取 与 options.cutDirection 相对应的 canvas 切片
  const canvasSections = getImageCanvasSections(loadedImg, { sectionWidth: options.sectionWidth, sectionHeight: options.sectionHeight, cutDirection: options.cutDirection })
  console.log('getBigImageSectionFiles canvasSections  ==> ', canvasSections)
  // TEST：append to document.body
  // canvasSections.forEach(itemCanvas => document.body.append(itemCanvas)) 
  // 获取 canvas 切片转 Blob 数组
  const blobPms = canvasSections.map(canvasItem => canvasToBlob(canvasItem))
  const blobResult = await Promise.all(blobPms)
  // Blob 数组 转 File 数组
  const fileList = blobResult.map((itemBlob, index) => new File([itemBlob], `section-${index}.png`, {type: itemBlob.type, lastModified: Date.now()}))
  return fileList
}

/**
 * @description 根据切片对图片进行缩放
 * @param {Image} loadedImg 
 * @param {Object} options 
 *                    sectionWidth: 切片宽度; 默认： 750
 *                    sectionHeight: 切片高度； 默认： 100
 *                    cutDirection: 描述：图片的切向； 可选： 'horizontal'<横切> | 'vertical'<纵切>; 默认： 'horizontal';
 *                    allowZoom: 是否允许缩放；可选：true | false; 默认： false
 * @returns {Image} loadedImg
 */
export function zoomImageForSection (loadedImg, options={}) {
  options = {
    sectionWidth: options.sectionWidth || 750, 
    sectionHeight: options.sectionHeight || 100,
    cutDirection: options.cutDirection || 'horizontal', 
    allowZoom: options.allowZoom || false
  }
  console.log('options ---> ', options)
  if (!options.allowZoom) return loadedImg
  switch (options.cutDirection) {
    case 'horizontal':
      loadedImg.width = options.sectionWidth
      loadedImg.height = Math.round(loadedImg.naturalHeight * loadedImg.width / loadedImg.naturalWidth)
      break;
    case 'vertical':
      loadedImg.height = options.sectionHeight
      loadedImg.width = Math.round(loadedImg.naturalWidth * loadedImg.height / loadedImg.naturalWidth)
  } 
  console.log('---> ', loadedImg.width, loadedImg.height)
  return loadedImg
}

/**
 * @description 获取图片 loadedImg 的 canvas 切片数组
 * @param {Image} loadedImg 
 * @param {Object} options 
 *                    sectionWidth: 切片宽度; 默认： 750
 *                    sectionHeight: 切片高度； 默认： 100
 *                    cutDirection: 描述：图片的切向； 可选： 'horizontal'<横切> | 'vertical'<纵切> ; 默认： 'horizontal';
 * @introduction 1. 当 cutDirection==='horizontal' 时，sectionHeight 起作用，sectionWidth 不起作用
 *              2. 当 cutDirection==='vertical' 时，sectionHeight 不起作用，sectionWidth 起作用  
 * @returns canvasSections
 */
 export function getImageCanvasSections (loadedImg, options) {
  options = { 
    sectionWidth: options.sectionWidth || 750, 
    sectionHeight: options.sectionHeight || 100,
    cutDirection: options.cutDirection || 'horizontal', 
  }
  // 获取 与 options.cutDirection 相对应的 canvas 切片
  const canvasSections =  options.cutDirection === 'vertical' ? getImageCanvasSectionsV(loadedImg, options.sectionWidth) :  getImageCanvasSectionsH(loadedImg, options.sectionHeight)
  return canvasSections
}

/**
 * @description 获取图片 img 的 横切后的 canvas 切片数组
 * @param {Image } img 【加载完成的目标图片对象】
 * @param {Number} cHeight 【canvas 切片的高度】
 * @return {Array} canvasArray
 */
export function getImageCanvasSectionsH (img, cHeight) {
  const canvasArray = []
  const imgWidth = img.width, 
        imgHeight = img.height,
        imgNaturalWidth = img.naturalWidth,
        imgNaturalHeight = img.naturalHeight,
        sectionZoomRatio = imgNaturalHeight / imgHeight
  let sx=0, sy=0 // 切图时的起始位置
  // 图片高度 小于 canvas 高度时，canvas.height=imgHeight, 切片数量也只有1个
  if (imgHeight <= cHeight) {
    const canvas = document.createElement('canvas')
    canvas.setAttribute('id', `canvas-single`)
    canvas.width = imgWidth
    canvas.height = imgHeight
    const ctx = canvas.getContext('2d')
    // ctx.drawImage(img, sx, sy, imgWidth, imgHeight, 0, 0, canvas.width, canvas.height)
    ctx.drawImage(img, sx, sy, canvas.width, canvas.height)
    canvasArray.push(canvas)
  }
  else {
    // 图片高度 大于 canvas 高度时，切片数量为 Math.ceil(imgHeight / cHeight) 个
    const sectionCount = Math.ceil(imgHeight / cHeight),
        remainHeight = imgHeight % cHeight
    // console.log('sectionCount, remainHeight : ', sectionCount, remainHeight)
    for (let i=1; i<=sectionCount; i++) {
      const canvas = document.createElement('canvas')
      canvas.setAttribute('id', `canvas-${i}`)
      canvas.width = imgWidth
      const ctx = canvas.getContext('2d')
      if (i===sectionCount && remainHeight !== 0) {
        canvas.height = remainHeight
      } else {
        canvas.height = cHeight
      }
      // ctx.drawImage(img, sx, sy, imgWidth, canvas.height, 0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, sx, sy, imgNaturalWidth, canvas.height * sectionZoomRatio, 0, 0, canvas.width, canvas.height)
      canvasArray.push(canvas)
      // sy = sy + canvas.height
      sy = sy +  canvas.height * sectionZoomRatio
    }
  }
  return canvasArray
}

/**
 * @description 获取图片 img 的 纵切后的 canvas 切片数组
 * @param {Image } img 【加载完成的目标图片对象】
 * @param {Number} cWidth 【canvas 切片的宽度】
 * @return {Array} canvasArray
 */
 export function getImageCanvasSectionsV (img, cWidth) {
  const canvasArray = []
  const imgWidth = img.width, 
        imgHeight = img.height,
        imgNaturalWidth = img.naturalWidth,
        imgNaturalHeight = img.naturalHeight,
        sectionZoomRatio = imgNaturalWidth / imgWidth
  let sx=0, sy=0 // 切图时的起始位置
  // 图片宽度 小于 canvas 宽度时，canvas.width=imgWidth, 切片数量也只有1个
  if (imgWidth <= cWidth) {
    const canvas = document.createElement('canvas')
    canvas.setAttribute('id', `canvas-single`)
    canvas.width = imgWidth
    canvas.height = imgHeight
    const ctx = canvas.getContext('2d')
    ctx.drawImage(img, sx, sy, canvas.width, canvas.height)
    canvasArray.push(canvas)
  }
  else {
    // 图片宽度 大于 canvas 宽度时，切片数量为 Math.ceil(imgWidth / cWidth) 个
    const sectionCount = Math.ceil(imgWidth / cWidth),
        remainWidth = imgWidth % cWidth
    // console.log('sectionCount, remainHeight : ', sectionCount, remainWidth)
    for (let i=1; i<=sectionCount; i++) {
      const canvas = document.createElement('canvas')
      canvas.setAttribute('id', `canvas-${i}`)
      canvas.height = imgHeight
      const ctx = canvas.getContext('2d')
      if (i===sectionCount && remainWidth !== 0) {
        canvas.width = remainWidth
      } else {
        canvas.width = cWidth
      }
      ctx.drawImage(img, sx, sy, canvas.width * sectionZoomRatio , imgNaturalHeight, 0, 0, canvas.width, canvas.height)
      canvasArray.push(canvas)
      sx = sx + canvas.width
    }
  }
  return canvasArray
}

/** image loaded, return Promise; */ 
const imageLoaded = async (newImg) => new Promise((resolve) => newImg.onload = () => resolve(newImg))

/**
 * @description 图片 img 转为 canvas，并获取其 canvas dom 对象
 * @param {Image } loadedImg 
 * @return {Canvas} canvas
 */
export function imageToCanvas (loadedImg, options={}) {
  options = {
    distorted: options.distorted || false,  // 是否允许失真
    canvWidth: options.canvWidth || 0,      // canvas 的 width
    canvHeight: options.canvHeight || 0,    // canvas 的 height
  }
  const canvas = document.createElement('canvas')
  const imgWidth = loadedImg.naturalWidth || loadedImg.width
  const imgHeight = loadedImg.naturalHeight || loadedImg.height
  // 确定 options.canvWidth 和 options.canvHeight
  if (!options.canvWidth && !options.canvHeight) {
    options.canvWidth = imgWidth
    options.canvHeight = imgHeight
  }
  else if (options.canvWidth && !options.canvHeight) {
    options.canvHeight = imgHeight / imgWidth * options.canvWidth
  }
  else if (!options.canvWidth && options.canvHeight) {
    options.canvWidth = imgWidth / imgHeight * options.canvHeight
  }
  else {
    if (!options.distorted) options.canvHeight = options.canvHeight = imgHeight / imgWidth * options.canvWidth
  }
  // 设置 canvas.width 和 canvas.height
  canvas.width = options.canvWidth || imgWidth
  canvas.height = options.canvHeight || imgHeight
  const ctx = canvas.getContext('2d')
  ctx.drawImage(loadedImg, 0, 0, imgWidth, imgHeight, 0, 0, canvas.width, canvas.height)
  return canvas
}

/**
 * @desction 获取 image file 的缩略图的 file 文件
 * @param {File} imgFile 
 * @param {Object} options 
 *                  thumbWidth: 缩略的宽度
 *                  thumbHeight: 缩略图的高度
 * @instruction 1. 当 options.thumbWidth && options.thumbHeight 时，缩略图以 options.thumbWidth 为基准进行等比缩放
 *              2. 当 options.thumbWidth && !options.thumbHeight 时，缩略图以 options.thumbWidth 为基准进行等比缩放
 *              3. 当 !options.thumbWidth && options.thumbHeight 时，缩略图以 options.thumbHeight 为基准进行等比缩放
 *              4. 当 !options.thumbWidth && !options.thumbHeight 时, 缩略图即为当前图片的大小
 * @return {File} thumbFile
 */
export async function imageFileToThumbFile (imgFile, options={}) {
  let thumbFile = imgFile
  options = {
    thumbWidth: options.thumbWidth || 0,
    thumbHeight: options.thumbHeight || 0,
  }
  // 没对 thumbWidth 和 thumbHeight 设置值时， thumbFile === imgFile
  if (!options.thumbWidth && !options.thumbHeight) return thumbFile
  // 把 imgFile 转为 image 实例
  const source = URL.createObjectURL(imgFile)
  const newImg = new Image()
  newImg.crossOrigin = "Anonymous"
  newImg.src = source
  // 获取加载后的 image 实例
  const loadedImg = await imageLoaded(newImg)
  // 实例已经加载完成，不再需要 source, 释放之前已经存在的、通过调用 URL.createObjectURL() 创建的 URL 对象;
  URL.revokeObjectURL(source); 
  // loaded image 转换为 canvas
  const thumbCanvas = imageToCanvas(loadedImg, { canvWidth: options.thumbWidth, canvHeight: options.thumbHeight, distorted: false })
  // thumb canvas 转换为 image file
  const thumbBlob = await canvasToBlob(thumbCanvas) // thumbCanvas transform to thumbBlob
  thumbFile = new File([thumbBlob], `thumb-image.png`, {type: thumbBlob.type, lastModified: Date.now()})
  return thumbFile
}

/**
 * @decription: canvas 转成 blob 二进制
 * @param {Canvas} canvasObj 
 * @param {String} transType  ： 要转成的文件类型，默认：'image/png'
 * @param {Number} transQuality : 0--1, 默认： 1
 * @returns {Promise} promise
 */
export function canvasToBlob (canvasObj, transType, transQuality) {
  const promise = new Promise((resolve, reject) => {
    const type = transType || 'image/png'
    const quality = transQuality || 1
    canvasObj.toBlob((blob) => { 
      // console.log('canvasToBlob blob ==> ', blob)
      blob ? resolve(blob) : reject(new Error('canvasToBlob error'))
    }, type, quality);
  })
  return promise
}

// export default
export default {
  getBigImageSectionFiles,
  imageFileToThumbFile,
  imageToCanvas,
  getImageCanvasSections,
  getImageCanvasSectionsH,
  getImageCanvasSectionsV,
  canvasToBlob
}
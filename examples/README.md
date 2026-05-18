## examples 说明

所有 HTML 文件均使用 `type="module"` 导入库，**需通过本地 HTTP 服务器打开**，不能直接双击（ `file://` 协议下 ES Module 跨域会报错）。

```bash
# 任意静态服务器均可，例如：
npx serve .
# 然后访问 http://localhost:3000/examples/
```

---

### Demo 文件

功能演示，不含断言，用于快速查看效果。

| 文件 | 对应方法 | 说明 |
| :--- | :--- | :--- |
| demo-get-big-image-section-files.html | `getBigImageSectionFiles` | 横切 / 纵切大图，展示切片列表 |
| demo-image-file-to-thumb-file.html | `imageFileToThumbFile` | 生成缩略图并展示 |
| demo-image-to-canvas.html | `imageToCanvas` | 图片转 canvas 并挂载到页面 |

---

### Test 文件

每个方法对应一个测试文件，含 `[PASS]` / `[FAIL]` 断言，可在浏览器中直接验证正确性。

| 文件 | 测试方法 | 测试用例 |
| :--- | :--- | :--- |
| test-get-big-image-section-files.html | `getBigImageSectionFiles` | 横切(allowZoom=true) + 纵切(allowZoom=false)，验证切片数量、文件类型、文件名格式 |
| test-image-file-to-thumb-file.html | `imageFileToThumbFile` | 4 种参数组合（双参/只宽/只高/无参），验证等比缩放和返回原始对象 |
| test-image-to-canvas.html | `imageToCanvas` | distorted=false/true、只传 canvWidth、无参，验证宽高行为 |
| test-zoom-image-for-section.html | `zoomImageForSection` | allowZoom=false / horizontal / vertical，验证 img.width/height 原地修改及等比缩放 |
| test-get-image-canvas-sections.html | `getImageCanvasSections` | 横切/纵切委托逻辑，与 H/V 版本结果对比 |
| test-get-image-canvas-sections-h.html | `getImageCanvasSectionsH` | 多片/单片/末尾余量三种场景 |
| test-get-image-canvas-sections-v.html | `getImageCanvasSectionsV` | 同上，纵向 |
| test-canvas-to-blob.html | `canvasToBlob` | 页面自动运行（无需上传），验证 Blob 类型/大小，覆盖 png/jpeg/webp |
| test-canvas-to-image-file.html | `canvasToImageFile` | 页面自动运行，验证 File 名称、MIME 类型、大小 |

# 《公羊传》Live2D 原生嵌入说明

## 改了什么

点「公羊传」白屏的原因：原来是用 `gree/unity-webview`（WebView2）去加载
`http://localhost:12393/gongyangzhuan` 这个 Open-LLM-VTuber 网页，网页里用
WebGL(SwiftShader) 画 Live2D。这套链路又重又脆（要起 Python 服务、WebGL 软渲染慢、
模型配置还指向了 mao_pro 而不是公羊传），所以经常白屏。

现在的做法：**用 Live2D Cubism SDK for Unity 直接在 Unity 里原生渲染模型**，
不再走网页，彻底去掉白屏。

改动文件：

- `Assets/StreamingAssets/Live2D/Gongyangzhuan/` —— 公羊传模型文件（已放入）
- `Assets/Scripts/Live2D/Live2DModelController.cs` —— 运行时加载 + 显示 + 眨眼/呼吸/眼珠游移
- `Assets/Scripts/Levels/GongyangLevel.cs` —— 改为原生 Live2D，不再用 WebView
- `Assets/Editor/SceneBuilder.cs` —— `BuildGongyangLevel` 同步更新

---

## 必须做的一步：导入 Cubism SDK for Unity

原生渲染依赖 Live2D 官方 SDK，**项目里目前没有**，需要你先下载导入。

1. 打开官方下载页（中文）：
   <https://www.live2d.com/zh-CHS/sdk/download/unity/>
2. 下载 **Cubism SDK for Unity**（当前 5.x，任意 R 版本都行，比如 5-r.1 或更新）。
   需要先同意 Live2D 的许可（免费；本项目 `server/LICENSE-Live2D.md` 已有该许可说明）。
3. 解压后得到一个 `CubismSdkForUnity-*.unitypackage`。
4. 回到 Unity（2022.3 LTS），菜单 **Assets → Import Package → Custom Package…**，
   选中那个 `.unitypackage`，**全选 Import**。
5. 打开 **Edit → Project Settings → Player → Other Settings → Scripting Define Symbols**，
   新增一个宏 **`LIVE2D_CUBISM`**（多个宏用分号 `;` 分隔）。

加了这个宏后，代码才会走 SDK 原生渲染分支。

> **没导入 SDK 时也不会报错、不会白屏**：代码里已经做了降级——没有 `LIVE2D_CUBISM`
> 宏时，会自动显示一张静态立绘（`Resources/Portraits/gongyangzhuan_portrait.png`）。
> 所以你可以先正常跑游戏，等 SDK 导入并加好宏后再切到动态 Live2D。

---

## 然后运行

两种方式任选：

- **A. 重新生成场景（推荐，最干净）**
  菜单 **Tools → 十三经 → Build All Scenes**。
  它会重建 `GongyangLevel` 场景并写入一个已配置好的 `Live2DModel` 物体。

- **B. 直接跑（不重新生成也能用）**
  旧场景里 `completeButton`、`hintText` 字段名没变，仍能对上；
  `Live2DModelController` 会在运行时自动创建。只是场景里会残留一个没用的
  「打开公羊传体验页」按钮（无害）。

运行后点「公羊传」进入关卡，应该能看到公羊传立绘并自动眨眼/呼吸。

---

## 调节模型大小/位置

选中场景里的 `Live2DModel` 物体，在 Inspector 里改 `Live2DModelController`：

- `cameraSize`：模型相机的正交视野（默认 6，越大模型看起来越小）
- `targetHeightFill`：模型占屏幕高度的比例（默认 0.82）
- `modelOffset`：模型中心相对屏幕中心的偏移
- `enableBlink / enableBreath / enableIdleLook`：动画开关
- `SetMouthOpen(float)`：脚本接口，接 TTS 后按音量驱动口型（参数 `ParamMouthOpenY`）

> 模型会自动按 Renderer 包围盒缩放（`AutoFit`），一般不用手动调 scale。

---

## 常见问题

- **编译报错 `Live2D.Cubism` 命名空间不存在** → 说明 SDK 还没导入，回到上面「必须做的一步」。
- **进关卡看不到人** → 确认 `StreamingAssets/Live2D/Gongyangzhuan/` 四个文件都在；
  再看 Console 有没有 `[Live2DModelController]` 的报错。
- **谷梁传也白屏** → 谷梁传目前还没有独立的 Live2D 模型（`live2d-models` 里只有
  `gongyangzhuan / mao_pro / shizuku`）。等有了模型，照 `GongyangLevel` 的样子复制一套即可。
- **为什么以前会一帧一帧卡？** → 以前是用 WebView2 加载网页，网页里用 WebGL(软件渲染)
  画 Live2D，而且整套 Open-LLM-VTuber 后端（ASR/TTS/LLM 模型 + Python + WASM）约 780MB，
  又慢又吃内存。原生 SDK 方案只用 ~1MB 的 `.moc3` + 贴图，直接走 GPU 渲染，本地读取，
  不联网、不起服务，所以能到 60 帧。

---

## 技术要点（给后续开发）

`Live2DModelController` 的结构：

```
Live2DModel（不缩放，挂控制器）
├── Live2DCamera（正交相机，z=-10，只渲染 Default 层 → RenderTexture，透明背景）
├── ModelRoot（只缩放这里，避免缩放相机）
│   └── CubismModel 层级（由 CubismModel3Json.ToModel() 生成）
└── （运行时在 Canvas 里生成全屏 RawImage 显示 RenderTexture）
```

加载入口是 `CubismModel3Json.LoadAtPath(...).ToModel()`，模型参数按
`.model3.json` 里的 `Groups`（EyeBlink → `ParamEyeLOpen/ParamEyeROpen`，
LipSync → `ParamMouthOpenY`）驱动。

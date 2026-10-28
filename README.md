# 典韵智创 · 十三经 IP 数字游戏

> 面向青少年群体的《十三经》IP 形象融合 + AI 赋能的剧情向数字游戏（Unity 2022.3 LTS / C#）

「典韵智创」把《十三经》的 13 部经典（周易、尚书、诗经、周礼、仪礼、礼记、左传、公羊传、谷梁传、论语、孝经、尔雅、孟子）人格化为可游玩的 IP 角色与关卡，并以 AI 数字人（Live2D + 大模型对话 + 语音）赋能经典文化教育。

本仓库包含两部分：

- **根目录**：Unity 工程本体（`Assets/` / `Packages/` / `ProjectSettings/` / `server/`）。
- **`flutter-demo/`**：同项目的早期 Flutter 展示版 App（橙光式 2D 数字人 + AI 对话），保留作参考。

---

## 一、玩法与内容

- **16 个场景**：主菜单、典籍大陆大地图、13 个关卡、结局。
- **13 个 IP 全部可玩**：
  - 2 个 **Live2D 语音对话关**（公羊传 / 谷梁传）：原生 Live2D 数字人 + 大模型对话 + 语音识别 / 合成。
  - 11 个 **剧情解谜关**（周易、尚书、诗经、周礼、仪礼、礼记、左传、论语、孝经、尔雅、孟子）。
- **收集与结局**：每完成一部经典标记为「已唤醒」，集齐 13 部进入结局并解锁特殊 CG。

## 二、技术栈

| 模块 | 技术选型 |
|------|----------|
| 引擎 | Unity 2022.3 LTS（2D）/ C# |
| UI | 内置 `UnityEngine.UI`（Canvas / Button / Text / Image） |
| 数字人 | Live2D Cubism SDK for Unity（原生渲染，眨眼 / 呼吸 / 口型同步） |
| AI 对话 | 内嵌 Open-LLM-VTuber（LLM 对话 + ASR + TTS） |
| 大模型 | DeepSeek（`openai` 兼容接口） |
| 场景切换 | `SceneManager.LoadSceneAsync`（异步加载 + 后台预载） |

## 三、目录结构

```
.
├── Assets/
│   ├── Scripts/
│   │   ├── Core/        # GameManager / SceneLoader / IPDatabase / LocalServerLauncher
│   │   ├── UI/          # MainMenu / WorldMap / IPButton / EndingScreen …
│   │   ├── Levels/      # 13 个关卡脚本 + DialogueLevelBase 基类
│   │   └── Live2D/      # Live2DModelController（原生渲染）
│   ├── Editor/          # SceneBuilder（一键生成全部场景）、BuildPostProcessor
│   ├── Prefabs/ Scenes/ Resources/ Backgrounds/ Audio/ StreamingAssets/
├── Packages/            # 依赖清单（ugui、gree/unity-webview、unity-mcp）
├── ProjectSettings/     # Unity 工程设置
├── server/              # 内嵌 Open-LLM-VTuber（AI 数字人服务端 + 前端 + 角色配置）
├── flutter-demo/        # 早期 Flutter 展示版 App（参考）
├── 打包发布.py           # 组装「免安装绿色版」单机包脚本
├── README.md            # 本文件
├── Live2D嵌入说明.md      # Live2D 原生接入说明
└── about.txt            # 内置音乐素材说明
```

> 各关卡脚本、场景搭建、打包流程的详细说明见仓库此前的中文开发文档；13 个关卡与
> 地图脚本已内置，推荐用 Unity 菜单 **Tools → 十三经 → Build All Scenes** 一键重建 16 个场景。

## 四、快速开始（开发）

**环境要求**：Unity 2022.3 LTS、Windows 10/11（64 位）、Python 3.11+（运行内嵌服务）、
可选 Live2D Cubism SDK for Unity 5.x。

1. 用 Unity Hub 打开本仓库根目录（Unity 2022.3 LTS）。
2. 首次打开后，等待包依赖解析完成（`Packages/manifest.json`）。
3. 打开 `Assets/Scenes/MainMenu.unity`，点击 Play 即可。
   - 若场景缺失，用菜单 **Tools → 十三经 → Build All Scenes** 重新生成。
4. **启用原生 Live2D（可选）**：导入 Cubism SDK，并在
   `Edit → Project Settings → Player → Other Settings → Scripting Define Symbols`
   加入宏 `LIVE2D_CUBISM`；未加宏时公羊传关卡自动降级为静态立绘，不会报错。

## 五、配置 AI 密钥（重要）

游戏内嵌的 Open-LLM-VTuber 服务需要一个大模型 API Key。出于安全考虑，
**仓库中所有密钥均以空字符占位，不会提交真实密钥**：

- `server/conf.yaml` → `llm_api_key: ''`
- `flutter-demo/lib/main.dart` → `defaultApiKey = ''`

运行前请填入你自己的 Key（示例为 DeepSeek）：

```yaml
# server/conf.yaml
llm_configs:
  openai_compatible_llm:
    base_url: 'https://api.deepseek.com/v1'
    llm_api_key: ''   # ← 在此填入你的 DeepSeek API Key
    model: 'deepseek-chat'
```

> ⚠️ 请勿把真实密钥提交回仓库。若曾提交过，请立即在平台侧轮换（废止旧 Key、生成新 Key）。
> 生产环境建议改为后端 / 云函数转发，避免密钥出现在客户端。

## 六、运行内嵌 AI 服务

```bash
cd server
# 方式一：使用 uv（推荐）
uv run run_server.py
# 服务启动后监听 http://localhost:12393
```

游戏启动时会自动拉起该服务（见 `Assets/Scripts/Core/LocalServerLauncher.cs`）；
打包为免安装版时，服务程序会随构建一起复制到 `server/run_server/`。

## 七、打包发布

```bash
# 先用 Unity 构建 Windows 版，再用脚本把「Unity 构建产物 + 内嵌服务 + 资源」组装为绿色版
python 打包发布.py --build <Unity构建输出目录>
# 输出目录：发布/十三经IP游戏/，整包压缩后即可分发
```

## 八、素材与许可

- 游戏音乐与美术素材来源于公开免费素材网站，部分场景框架参考他人素材，由参赛者整合与二次开发。
- 内嵌的 Open-LLM-VTuber 遵循其自身许可；Live2D 相关许可见 `server/LICENSE-Live2D.md`。
- 本项目仅供学习、展示与参赛使用。

---

*典韵智创 · 让经典与青春对话*

# QQ人 Live2D 模型接入指南

> 这个文件夹里现在放的是 **Cubism 编辑器源文件**，网页运行时还不能直接用。按下面步骤操作即可。

## 一、你现在的文件是什么？

| 文件 | 类型 | 能否直接用 |
|------|------|-----------|
| `QQ人.cmo3` | Cubism 编辑器**模型源文件**（CAFF 格式） | ❌ 不能 |
| `QQ人.can3` | Cubism 编辑器**动画源文件**（CAFF 格式） | ❌ 不能 |

Open-LLM-VTuber 的网页端（Cubism 4 Web SDK）只认**运行时导出格式**：`.moc3` + `.model3.json`。
所以 `.cmo3` / `.can3` 必须先在 Cubism Editor 里「导出为运行时文件」。

## 二、在 Cubism Editor 里导出运行时文件

1. 用 **Live2D Cubism Editor**（3.x / 4.x / 5.x 都行）打开 `QQ人.cmo3`
2. 菜单：**文件 → 导出 → 运行时文件**（英文 `File → Export → For Runtime`；
   不同版本可能叫「嵌入用文件」/「組み込み用データ書き出し」）
3. 选择一个导出目录，会生成一个带 `runtime/` 子目录的文件夹，里面大致包含：

```
QQ人/
  runtime/
    QQ人.moc3            ← 模型本体
    QQ人.model3.json     ← 入口配置（最重要的文件）
    QQ人.physics3.json   ← 物理（如有）
    QQ人.pose3.json      ← 姿态（如有）
    QQ人.cdi3.json       ← 显示信息
    QQ人.4096/texture_00.png  ← 贴图（1024/2048/4096 取决于导出设置）
    motions/*.motion3.json     ← 动作
    expressions/*.exp3.json    ← 表情
```

> 如果模型是别人做的、你没有编辑器，就让做模型的人做这一步（1 分钟的事），
> 直接把导出的 `runtime/` 文件夹发给你。

## 三、放到项目里

把导出的**整个文件夹**（含 `runtime/`）复制到项目根目录的 `live2d-models/` 下：

```
live2d-models/QQ人/runtime/QQ人.model3.json   ← 最终入口
```

（文件夹名用英文更稳妥，比如 `QQren` 或 `qq`；文件名保持导出原样即可。）

## 四、注册模型：编辑 `model_dict.json`

在项目根目录 `model_dict.json` 里，仿照已有的 `mao_pro` 加一条：

```json
{
  "name": "QQ人",
  "url": "/live2d-models/QQ人/runtime/QQ人.model3.json",
  "kScale": 0.5,
  "initialXshift": 0,
  "initialYshift": 0,
  "kXOffset": 1150,
  "idleMotionGroupName": "Idle",
  "emotionMap": {
    "neutral": 0,
    "joy": 1,
    "sadness": 1,
    "surprise": 1,
    "anger": 1,
    "disgust": 1,
    "fear": 1,
    "smirk": 1
  },
  "tapMotions": {}
}
```

> ⚠️ 上面的 `emotionMap` 数字（表情索引）和 `idleMotionGroupName`（待机动作组名）
> 要按你导出的模型实际情况填：打开 `QQ人.model3.json` 看 `Expressions` 和 `Motions`
> 分组名，`0/1/2...` 对应第几个表情。`mao_pro` 的可直接照抄格式。

## 五、切换角色使用该模型

改 `conf.yaml` 或 `characters/zhouyi.yaml` 里这一行：

```yaml
live2d_model_name: 'QQ人'
```

## 六、前端（web 界面）状态

- 已把编译好的前端放进了 `frontend/`（来自本地
  `F:/二次元桌面小游戏/model/Open-LLM-VTuber-Web-main/dist/web`）。
- 以后代理恢复后，也可重新执行 `git submodule update --init --recursive` 拿到官方版本。

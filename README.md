# 典韵智创 · AI 数字人展示版

> 十三经 IP 数字化可行性展示 Demo —— 2D 数字人 + AI 对话 + 剧情分支

## 📖 项目简介

「典韵智创」是一款橙光式 2D 数字人交互 App，将十三经经典典籍人格化为可对话的 AI 数字人。用户可以选择典籍角色，体验短剧情，与角色自由对话，观察好感度变化。

### 核心功能

- 🎭 **6 位典籍角色**：周易、论语、诗经、尚书、周礼、孝经
- 💬 **AI 自由对话**：基于 DeepSeek 大模型，每位角色有独立人设
- 📖 **剧情分支**：每角色 3-5 分钟剧情，含 2-3 个分支选择
- ❤️ **好感度系统**：剧情选择和对话内容影响好感度
- 💾 **本地存档**：对话记录、好感度自动保存

## 🚀 快速开始

### 直接安装

下载 `app-release.apk` 安装到 Android 设备即可使用。

### 开发环境

```bash
# 克隆项目
git clone https://github.com/hong-red/dianyun-zhichuang.git
cd dianyun_zhichuang

# 安装依赖
flutter pub get

# 运行
flutter run

# 构建 APK
flutter build apk --release
```

### API Key 配置

在 `lib/main.dart` 中修改 `defaultApiKey` 为你的 DeepSeek API Key：

```dart
static const String defaultApiKey = 'your-api-key-here';
```

> ⚠️ 展示版直接在前端配置 API Key 仅用于演示。生产环境请务必通过云函数/后端转发，避免密钥泄露。

## 🏗️ 技术架构

| 模块 | 技术选型 |
|------|----------|
| 前端 | Flutter (Android) |
| AI 大模型 | DeepSeek API |
| 本地存储 | SharedPreferences |
| 架构 | 前端直接调用 API（展示版） |

## 📱 角色一览

| 角色 | 类型 | 性格 | 代表色 |
|------|------|------|--------|
| 周易 | 智者型 | 沉着冷静、神秘深邃 | 灰金色 |
| 论语 | 导师型 | 温文尔雅、循循善诱 | 暖褐色 |
| 诗经 | 治愈型 | 温柔知性、善解人意 | 青绿色 |
| 尚书 | 领袖型 | 威严稳重、坚决果断 | 深紫色 |
| 周礼 | 管理者型 | 干练潇洒、权威务实 | 墨绿色 |
| 孝经 | 少年型 | 率真纯真、坚毅果敢 | 橘橙色 |

## 📝 项目结构

```
lib/
├── main.dart                    # 入口
├── models/                      # 数据模型
│   ├── character.dart
│   ├── chat_message.dart
│   └── story.dart
├── data/                        # 角色和剧情数据
│   ├── characters.dart
│   └── stories.dart
├── services/                    # 服务层
│   ├── ai_service.dart          # AI 对话服务
│   └── storage_service.dart     # 本地存储服务
├── pages/                       # 页面
│   ├── character_select_page.dart  # 角色选择页
│   ├── chat_page.dart           # 对话页
│   └── story_page.dart          # 剧情页
└── widgets/                     # 组件
    ├── character_avatar.dart
    └── affinity_bar.dart
```

## 📄 License

本项目仅供学习和展示使用。

---

*典韵智创 · 让经典与青春对话*

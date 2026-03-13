# SuppCheck - 补剂摄入记录

一款简洁优雅的补剂摄入记录应用，帮助您规律服用、防止漏服和过量。

## ✨ 功能特性

- 📋 **补剂管理** - 记录各种补剂的剂量、服用频率和库存
- ✅ **今日打卡** - 一键记录服用，实时显示完成进度
- 📅 **日历视图** - 查看历史记录，追踪服用习惯
- 📊 **统计分析** - 服用率趋势图表，连续打卡天数
- 🔔 **提醒管理** - 独立的提醒设置页面，可开关每个提醒
- ⚠️ **智能防过量** - 达到每日上限自动提醒，防止重复服用
- 🏷️ **分类标签** - 维生素/蛋白质/益生菌等10种分类
- ↩️ **撤销记录** - 左滑撤销误操作，自动恢复库存
- 💾 **数据备份** - 支持导出/导入JSON，数据不丢失
- 🔥 **连续打卡** - 自动统计连续服用天数

## 🎨 设计特点

- 苹果风格设计，简约高级
- 流畅的交互动效
- 明暗适中的配色方案
- 清晰的信息层级

## 🛠️ 技术栈

- **Flutter** - 跨平台开发框架
- **SQLite** - 本地数据存储
- **Provider** - 状态管理
- **flutter_local_notifications** - 本地通知

## 📱 运行项目

### 1. 安装 Flutter

访问 [Flutter 官网](https://docs.flutter.dev/get-started/install) 下载安装。

### 2. 安装依赖

```bash
cd E:\SLU\code\suppcheck
flutter pub get
```

### 3. 运行应用

```bash
# iOS 模拟器
flutter run

# Android 模拟器
flutter run -d android

# 真机调试
flutter run -d <device_id>
```

### 4. 构建发布版本

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

## 📂 项目结构

```
lib/
├── main.dart                   # 应用入口
├── models/
│   └── supplement.dart         # 数据模型（含分类枚举）
├── providers/
│   └── supplement_provider.dart    # 状态管理
├── screens/
│   ├── home_screen.dart        # 主页（导航）
│   ├── today_screen.dart       # 今日打卡（含连续打卡）
│   ├── calendar_screen.dart    # 日历
│   ├── statistics_screen.dart  # 统计
│   ├── supplement_list_screen.dart   # 补剂列表
│   ├── add_supplement_screen.dart    # 添加/编辑
│   ├── settings_screen.dart    # 设置（数据备份）
│   └── reminders_screen.dart   # 提醒管理
├── services/
│   ├── database_service.dart   # 数据库操作
│   └── notification_service.dart   # 本地通知
├── utils/
│   └── constants.dart          # 常量定义
└── widgets/
    ├── supplement_card.dart    # 补剂卡片组件
    └── today_records_list.dart   # 今日记录列表
```

## 📦 依赖说明

| 包名 | 用途 |
|------|------|
| sqflite | SQLite 数据库 |
| flutter_local_notifications | 本地通知 |
| shared_preferences | 轻量设置存储 |
| provider | 状态管理 |
| table_calendar | 日历组件 |
| fl_chart | 图表统计 |
| intl | 日期国际化 |
| share_plus | 分享功能（数据导出）|
| permission_handler | 权限管理 |

## 📝 更新日志

### v1.1.0 (2026-03-04)
- ✨ 新增撤销服用功能，左滑即可撤销
- ✨ 新增连续打卡天数统计
- ✨ 新增补剂分类标签（10种分类）
- ✨ 新增数据备份与导入功能
- ✨ 新增独立的提醒管理页面
- 🐛 修复日历历史记录查询
- 🐛 优化今日页面显示今日记录列表

### v1.0.0 (2026-03-01)
- 🎉 首次发布

## 📝 后续开发计划

- [ ] 用药周期设置（如吃5停2）
- [ ] 与家人共享数据（需云端）
- [ ] 智能推荐服用时间
- [ ] 补剂相互作用提醒
- [ ] 导出CSV/PDF报告

## 📄 开源协议

MIT License

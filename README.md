# SuppCheck

SuppCheck 是一款使用 Flutter 开发的补剂摄入记录应用，用于管理日常补剂、记录服用情况并降低漏服或重复服用的可能。

项目采用本地优先的设计，数据保存在设备端，无需注册账号或连接远程服务。

## 主要功能

- 管理补剂名称、剂量、服用频率与库存
- 记录每日服用情况并查看完成进度
- 在日历中查询历史记录
- 统计服用率与连续记录天数
- 为不同补剂配置本地提醒
- 达到每日服用上限时进行提示
- 按补剂类型进行分类
- 撤销误操作并恢复对应库存
- 导入和导出本地数据

## 技术栈

| 用途 | 技术 |
| --- | --- |
| 应用框架 | Flutter |
| 状态管理 | Provider |
| 本地数据库 | SQLite、sqflite |
| 本地通知 | flutter_local_notifications |
| 日历 | table_calendar |
| 图表 | fl_chart |
| 本地设置 | shared_preferences |

## 环境要求

- Flutter SDK
- Dart SDK 3.0 或更高版本
- Android Studio 或 Xcode，具体取决于目标平台

可使用以下命令确认本地开发环境是否完整：

```bash
flutter doctor
```

## 开始使用

克隆项目并进入项目目录：

```bash
git clone https://github.com/Oscar-Ming/suppcheck.git
cd suppcheck
```

安装依赖：

```bash
flutter pub get
```

查看可用设备：

```bash
flutter devices
```

运行应用：

```bash
flutter run
```

也可以指定设备：

```bash
flutter run -d <device_id>
```

## 构建

构建 Android APK：

```bash
flutter build apk --release
```

构建 Android App Bundle：

```bash
flutter build appbundle --release
```

在 macOS 上构建 iOS 版本：

```bash
flutter build ios --release
```

## 项目结构

```text
lib/
|-- main.dart
|-- models/          数据模型
|-- providers/       状态管理
|-- screens/         应用页面
|-- services/        数据库与通知服务
|-- utils/           常量与通用工具
`-- widgets/         可复用组件
```

## 数据与权限

应用数据默认保存在本地 SQLite 数据库中。提醒功能需要系统通知权限；不同平台可能还需要额外的通知或精确闹钟配置。

在导入数据前，建议先导出一份当前数据作为备份。

## 开发检查

运行静态分析：

```bash
flutter analyze
```

运行测试：

```bash
flutter test
```

## 许可证

本项目使用 MIT License。

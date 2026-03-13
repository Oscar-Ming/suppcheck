# SuppCheck 环境搭建指南

## 第一步：安装 Flutter SDK

### Windows 安装

1. **下载 Flutter SDK**
   - 访问 https://docs.flutter.dev/get-started/install/windows
   - 下载 `flutter_windows_3.x.x-stable.zip`

2. **解压并配置环境变量**
   ```powershell
   # 解压到 C:\flutter
   # 添加环境变量 PATH: C:\flutter\bin
   ```

3. **验证安装**
   ```powershell
   flutter doctor
   ```

## 第二步：配置 Android 开发环境（如需要 Android 版）

1. **安装 Android Studio**
   - 下载地址：https://developer.android.com/studio

2. **安装 SDK 和工具**
   - Android SDK
   - Android SDK Command-line Tools
   - Android SDK Build-Tools
   - Android Emulator (可选)

3. **配置环境变量**
   ```powershell
   # 添加 ANDROID_HOME
   # 添加 PATH: %ANDROID_HOME%\platform-tools
   ```

## 第三步：配置 iOS 开发环境（如需要 iOS 版）

> ⚠️ **需要 macOS + Xcode**

1. **安装 Xcode** (Mac App Store)

2. **安装 CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

3. **配置模拟器**
   ```bash
   # 打开 Xcode -> Preferences -> Components
   # 下载 iOS Simulator
   ```

## 第四步：项目初始化

```powershell
# 进入项目目录
cd E:\SLU\code\suppcheck

# 获取依赖
flutter pub get

# 检查环境
flutter doctor
```

## 第五步：运行应用

```powershell
# 查看可用设备
flutter devices

# 运行到可用设备
flutter run

# 或指定设备
flutter run -d <device_id>
```

## 常见问题

### Q: flutter 命令无法识别
**A:** 检查环境变量 PATH 是否包含 flutter\bin 目录

### Q: Android 模拟器无法启动
**A:** 
1. 确保已安装 Intel HAXM 或 AMD Hyper-V
2. 在 Android Studio 中创建虚拟设备

### Q: iOS 构建失败
**A:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### Q: 通知权限问题
**A:** 
- Android: 需要在设置中开启通知权限
- iOS: 首次启动时会弹出权限请求，点击"允许"

## 下一步

环境配置完成后，即可开始开发或运行应用。

如有问题，参考 Flutter 官方文档：https://flutter.dev/docs

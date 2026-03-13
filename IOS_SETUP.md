# iOS 设置与开发指南

## 项目状态

✅ iOS 基础配置已完成：
- Info.plist 已添加通知权限配置
- AppDelegate.swift 已配置本地通知支持
- Podfile 已创建并配置

---

## Windows 用户的 iOS 开发方案

由于 Xcode 只能在 macOS 上运行，Windows 用户有以下选择：

### 方案 1：使用 macOS 虚拟机（不推荐）
**难度：** ⚠️ 复杂，违反 Apple EULA

### 方案 2：租用 Mac 云服务器（推荐）
**难度：** ⭐ 简单

推荐服务：
| 服务 | 价格 | 网址 |
|------|------|------|
| MacStadium | $99/月起 | https://www.macstadium.com |
| AWS EC2 Mac | $1.083/小时 | https://aws.amazon.com/ec2/instance-types/mac |
| Scaleway | €0.10/小时 | https://www.scaleway.com |

**步骤：**
1. 租用 Mac 服务器
2. 通过远程桌面连接
3. 安装 Xcode 和 Flutter
4. 克隆项目并运行

### 方案 3：使用 CI/CD 服务构建（最推荐）
**难度：** ⭐⭐ 中等

推荐服务：
| 服务 | 免费额度 | 特点 |
|------|----------|------|
| Codemagic | 500分钟/月 | 专为 Flutter 设计 |
| GitHub Actions | 2000分钟/月 | 需 macOS runner |
| Bitrise | 200分钟/月 | 移动端专用 |

---

## Codemagic 快速配置

### 1. 注册并连接仓库
1. 访问 https://codemagic.io
2. 用 GitHub/GitLab/Bitbucket 账号登录
3. 导入 SuppCheck 项目

### 2. 创建 codemagic.yaml

在项目根目录创建 `codemagic.yaml`：

```yaml
workflows:
  ios-build:
    name: iOS Build
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Get Flutter packages
        script: flutter packages pub get
      - name: Install pods
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS
        script: flutter build ios --release --no-codesign
    artifacts:
      - build/ios/iphoneos/*.app
      - build/ios/ipa/*.ipa
```

### 3. 配置 Apple Developer 账号（可选）
- 免费账号：可构建但不发布
- 付费账号（$99/年）：可发布到 App Store

### 4. 开始构建
点击 "Start new build"，选择 iOS 工作流

---

## 在 macOS 上的本地开发

### 前提条件
1. macOS 10.14 或更高版本
2. Xcode 14.0 或更高版本
3. CocoaPods: `sudo gem install cocoapods`

### 首次构建步骤

```bash
# 1. 进入项目目录
cd /path/to/suppcheck

# 2. 获取 Flutter 依赖
flutter pub get

# 3. 进入 iOS 目录并安装 Pod
cd ios
pod install --repo-update

# 4. 返回项目根目录
cd ..

# 5. 运行 iOS 模拟器
flutter run
```

### 真机测试步骤

```bash
# 1. 打开 Xcode
open ios/Runner.xcworkspace

# 2. 在 Xcode 中配置：
#    - 选择 Target: Runner
#    - Signing & Capabilities
#    - 登录 Apple ID
#    - 选择 Team
#    - 修改 Bundle Identifier（确保唯一）

# 3. 连接 iPhone，选择设备运行
flutter run -d <device-id>
```

---

## iOS 配置详情

### Info.plist 已配置

```xml
<!-- 后台模式 -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
    <string>processing</string>
</array>

<!-- 通知权限描述 -->
<key>NSUserNotificationUsageDescription</key>
<string>SuppCheck 需要发送通知来提醒您按时服用补剂，防止漏服或过量。</string>
```

### AppDelegate.swift 已配置

支持的功能：
- ✅ 前台显示通知
- ✅ 本地通知权限请求
- ✅ 通知点击处理

### Podfile 已配置

- 最低 iOS 版本: 12.0
- 支持 flutter_local_notifications
- 修复 Xcode 15+ 兼容问题

---

## 发布到 App Store

### 1. 准备材料
- [ ] 应用图标（1024x1024）
- [ ] 截图（iPhone 6.5"、iPhone 5.5"、iPad）
- [ ] 应用描述
- [ ] 隐私政策 URL
- [ ] 联系人信息

### 2. 构建发布版本

```bash
# 清理构建
flutter clean

# 获取依赖
flutter pub get

# 进入 iOS 目录
cd ios

# 更新 pods
pod install --repo-update

# 打开 Xcode
open Runner.xcworkspace
```

### 3. 在 Xcode 中：
1. 选择 Product → Scheme → Runner
2. 选择 Product → Destination → Any iOS Device
3. 选择 Product → Archive
4. 等待构建完成
5. 在 Organizer 中选择 Archive，点击 Distribute App
6. 选择 App Store Connect → Upload

---

## 常见问题

### Q: Windows 上无法运行 iOS 模拟器？
**A:** 这是正常的，iOS 模拟器只能在 macOS 上运行。使用上述方案 2 或 3。

### Q: 构建时出现 CocoaPods 错误？
**A:** 在 macOS 上运行：
```bash
cd ios
sudo gem install cocoapods
pod setup
pod install --repo-update
```

### Q: 通知不显示？
**A:** 
1. 首次启动时会请求权限，点击"允许"
2. 检查 iOS 设置 → 通知 → SuppCheck 是否开启
3. 检查 Info.plist 配置是否正确

### Q: 后台提醒不工作？
**A:** iOS 限制了后台任务频率，建议使用精确时间的本地通知。

---

## 下一步行动

对于 Windows 用户：

1. **立即体验：** 使用 Codemagic 免费构建 iOS 版本
2. **长期方案：** 考虑购买 Mac mini 或租用云 Mac
3. **团队协作：** 如果有 Mac 用户，可请他们协助测试

---

## 相关链接

- [Flutter iOS 部署官方文档](https://docs.flutter.dev/deployment/ios)
- [Codemagic Flutter 文档](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/)
- [flutter_local_notifications iOS 设置](https://pub.dev/packages/flutter_local_notifications#ios-setup)

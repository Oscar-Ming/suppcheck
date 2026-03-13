# Android 通知配置说明

## 必需配置

创建或修改以下文件：

### 1. android/app/src/main/AndroidManifest.xml

添加通知权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 通知权限 -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <application
        android:label="SuppCheck"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ... 其他配置 ... -->
        
        <!-- 通知接收器 -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        
    </application>
</manifest>
```

### 2. android/app/build.gradle

确保 minSdkVersion 设置正确：

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // 或更高
        targetSdkVersion 34
    }
}
```

### 3. 通知图标

在 `android/app/src/main/res/drawable/` 放置通知图标：
- `ic_launcher.png` - 应用图标
- 或创建 `ic_stat_icon.png` 作为通知小图标

## 运行

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
flutter run
```

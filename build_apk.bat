@echo off
chcp 65001 >nul
echo ===================================
echo   SuppCheck v1.1.0 构建脚本
echo ===================================
echo.

cd /d "%~dp0"

echo [1/3] 清理旧构建...
flutter clean

echo [2/3] 获取依赖...
flutter pub get

echo [3/3] 构建 Release APK...
flutter build apk --release

if %errorlevel% == 0 (
    echo.
    echo ===================================
    echo   ✅ 构建成功！
    echo ===================================
    echo.
    echo APK 位置：
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 安装命令：
    echo adb install build\app\outputs\flutter-apk\app-release.apk
    echo.
    pause
) else (
    echo.
    echo ===================================
    echo   ❌ 构建失败
    echo ===================================
    pause
)

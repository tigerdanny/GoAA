@echo off
echo ====================================
echo       GOAA Logo 設置腳本
echo ====================================
echo.

echo 📋 檢查必要文件...
if not exist "assets\icons\app_icon.png" (
    echo ❌ 找不到 assets\icons\app_icon.png
    echo    請將您的logo圖片保存到此位置
    echo.
    pause
    exit /b 1
)

if not exist "assets\images\goaa_logo.png" (
    echo ❌ 找不到 assets\images\goaa_logo.png  
    echo    請將您的logo圖片保存到此位置
    echo.
    pause
    exit /b 1
)

echo ✅ 圖片文件已找到

echo.
echo 🔧 安裝Flutter依賴...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Flutter依賴安裝失敗
    pause
    exit /b %errorlevel%
)

echo.
echo 🎨 生成應用圖標...
call flutter pub run flutter_launcher_icons
if %errorlevel% neq 0 (
    echo ⚠️ 圖標生成遇到問題，但繼續執行...
)

echo.
echo 🌅 生成啟動畫面...
call flutter pub run flutter_native_splash:create
if %errorlevel% neq 0 (
    echo ⚠️ 啟動畫面生成遇到問題，但繼續執行...
)

echo.
echo 🧹 清理舊建置...
call flutter clean

echo.
echo 🔨 重新建置應用...
call flutter build apk
if %errorlevel% neq 0 (
    echo ❌ 應用建置失敗
    pause
    exit /b %errorlevel%
)

echo.
echo 🎉 設置完成！
echo.
echo 📱 要安裝到設備，請運行：
echo    flutter install
echo.
echo ✨ 您的GOAA應用現在使用您的原始logo了！
pause 

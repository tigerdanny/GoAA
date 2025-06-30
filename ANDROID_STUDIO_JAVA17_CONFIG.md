# Android Studio Java 17 配置指南

## 🚀 已完成的配置

✅ **系統環境變量**: JAVA_HOME = `C:\Program Files\Java\jdk-17`
✅ **Flutter 配置**: 已設置使用 Java 17
✅ **Gradle 配置**: 所有項目配置文件已更新為 Java 17
✅ **緩存清理**: 已清除所有 Gradle 和 Flutter 緩存

## 📋 Android Studio 配置步驟

### 1. 配置 Android Studio 使用 Java 17

1. **開啟 Android Studio**
2. **前往設置**:
   - `File` → `Settings` (Windows/Linux)
   - 或 `Android Studio` → `Preferences` (macOS)
   - 快捷鍵: `Ctrl+Alt+S` (Windows/Linux) 或 `Cmd+,` (macOS)

3. **設置 Gradle JVM**:
   - 在左側面板搜索 "Gradle"
   - 選擇 `Build, Execution, Deployment` → `Build Tools` → `Gradle`
   - 在 "Gradle JVM" 下拉選單中選擇或設置:
     ```
     C:\Program Files\Java\jdk-17
     ```
   - 點擊 `Apply` 和 `OK`

### 2. 配置項目特定設置（如果需要）

1. **開啟項目設置**:
   - `File` → `Project Structure` 或 `Ctrl+Alt+Shift+S`
   
2. **設置 Project SDK**:
   - 在 "Project" 選項卡中
   - 設置 "Project SDK" 為 Java 17
   
3. **設置 Module SDK**:
   - 在 "Modules" 選項卡中
   - 確保所有模組的 "Module SDK" 都設置為 Java 17

### 3. 配置 IntelliJ IDEA (如果使用)

1. **前往設置**: `File` → `Settings`
2. **設置 Build Tools**: `Build, Execution, Deployment` → `Build Tools` → `Gradle`
3. **設置 Gradle JVM**: 選擇 `C:\Program Files\Java\jdk-17`

## 🔄 重啟和驗證

### 1. 重啟所有工具
- 重啟 Android Studio
- 重啟 VS Code/其他 IDE
- 重啟終端/命令提示符

### 2. 驗證配置
```bash
# 檢查 Flutter 環境
flutter doctor --verbose

# 檢查 Java 版本
java -version

# 檢查環境變量
echo $env:JAVA_HOME  # PowerShell
echo %JAVA_HOME%     # CMD
```

### 3. 測試構建
```bash
# 清理項目
flutter clean

# 構建 APK
flutter build apk --debug
```

## 🐛 常見問題解決

### 問題 1: Android Studio 仍然使用舊版本 Java
**解決方案**:
1. 完全關閉 Android Studio
2. 刪除 Android Studio 緩存: `%USERPROFILE%\.AndroidStudio*`
3. 重新開啟 Android Studio
4. 重新配置 Gradle JVM

### 問題 2: Gradle 仍然找不到 Java 17
**解決方案**:
1. 確認 Java 17 安裝路徑: `C:\Program Files\Java\jdk-17\bin\java.exe`
2. 檢查系統 PATH 環境變量
3. 重新運行 `setup_jdk17.bat` 腳本

### 問題 3: Flutter 構建失敗
**解決方案**:
1. 運行 `flutter clean`
2. 刪除 `android\build` 和 `android\app\build` 目錄
3. 重新運行 `flutter build apk --debug`

## 📞 支援

如果遇到問題，請檢查:
1. Java 17 是否正確安裝在 `C:\Program Files\Java\jdk-17`
2. 所有 IDE 是否已重啟
3. 環境變量是否正確設置
4. Gradle 緩存是否已清除

## 🎯 下一步

1. 重啟 Android Studio 和其他 IDE
2. 按照上述步驟配置 Android Studio
3. 運行 `flutter doctor --verbose` 驗證配置
4. 嘗試構建項目: `flutter build apk --debug` 

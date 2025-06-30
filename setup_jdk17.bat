@echo off
echo Setting up JDK 17 environment for Android development...

REM 設置 JAVA_HOME 環境變量為 JDK 17
setx JAVA_HOME "C:\Program Files\Java\jdk-17"
set JAVA_HOME=C:\Program Files\Java\jdk-17

REM 配置 Flutter 使用 Java 17
echo Configuring Flutter to use Java 17...
flutter config --jdk-dir="C:\Program Files\Java\jdk-17"

REM 清除所有 Gradle 緩存
echo Cleaning all Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul

REM 清除項目構建緩存
echo Cleaning project build caches...
rmdir /s /q "goaa_flutter\android\build" 2>nul
rmdir /s /q "goaa_flutter\android\app\build" 2>nul
rmdir /s /q "goaa_flutter\android\.gradle" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul

REM 創建全局 Gradle 配置（JDK 17）
echo Creating global Gradle configuration for JDK 17...
mkdir "%USERPROFILE%\.gradle" 2>nul
echo org.gradle.java.home=C:\Program Files\Java\jdk-17 > "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m -XX:+UseG1GC >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.parallel=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.daemon=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo android.useAndroidX=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo android.enableJetifier=true >> "%USERPROFILE%\.gradle\gradle.properties"

echo.
echo ========================================
echo JDK 17 setup completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Restart your IDE (Android Studio/VS Code)
echo 2. Restart your terminal/command prompt
echo 3. Run: flutter doctor --verbose
echo 4. Run: flutter clean
echo 5. Run: flutter build apk --debug
echo.
echo If you still see JDK errors, make sure you have JDK 17 installed:
echo https://docs.microsoft.com/en-us/java/openjdk/download#openjdk-17
echo.
pause 

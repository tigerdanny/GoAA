# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter 相關規則
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLite 相關規則
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Drift 資料庫相關規則
-keep class drift.** { *; }
-keep class com.simolus.drift.** { *; }

# 防止 native 庫被混淆
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# 保持所有 native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保持所有序列化相關類
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保持所有 Parcelable 實現
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# 保持所有註解
-keepattributes *Annotation*

# 保持泛型簽名
-keepattributes Signature

# 保持異常信息
-keepattributes Exceptions 

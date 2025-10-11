# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keepattributes *Annotation*

# Android Play Core (for Flutter's deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Split Support
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# SQLite and database related
-keep class android.database.** { *; }
-keep class org.sqlite.** { *; }

# Local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Shared Preferences
-keep class android.content.SharedPreferences** { *; }

# JSON serialization (if using)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prayer times API and network requests
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# HTTP client for Aladhan API
-keep class java.net.http.** { *; }
-keep class org.apache.http.** { *; }

# Prevent obfuscation of model classes for Subh Warrior app
-keep class com.subhwarrior.app.models.** { *; }
-keep class com.subhwarrior.app.data.** { *; }
-keep class com.subhwarrior.app.repositories.** { *; }
-keep class com.subhwarrior.app.services.** { *; }

# Keep Islamic/Arabic text rendering classes
-keep class android.text.** { *; }
-keep class android.graphics.Typeface** { *; }

# GoRouter navigation
-keep class ** implements go_router.** { *; }

# Showcase/tutorial system
-keep class showcaseview.** { *; }

# Isolate computation (for performance optimization)
-keep class dart.** { *; }

# Prevent optimization of classes that might be accessed via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# General Android rules
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Remove debug logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimize and remove unused code
-optimizationpasses 5
-dontpreverify
-repackageclasses ''
-allowaccessmodification
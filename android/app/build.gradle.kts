import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing — credentials live in android/key.properties (gitignored)
// or are materialized from CI secrets. Falls back to debug signing locally
// when the file is absent so `flutter run` still works.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val hasReleaseSigning = keystorePropertiesFile.exists()

val flutterMinSdk: Int by extra(24)
val flutterTargetSdk: Int by extra(36)

android {
    namespace = "com.subhwarrior.app"
    compileSdk = rootProject.extra["compileSdkVersion"] as Int
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.subhwarrior.app"
        minSdk = flutterMinSdk
        targetSdk = flutterTargetSdk
        // Sourced from pubspec.yaml's `version: <name>+<code>` — the Flutter
        // tool writes it into android/local.properties on every build, which
        // the Flutter Gradle plugin exposes here. These used to be hardcoded
        // to 1 / "1.0.0", so every APK shipped as 1.0.0(1) no matter what
        // pubspec said, on CI and locally alike.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Use the real release key when present; otherwise debug so local
            // release builds don't fail. CI must provide key.properties.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))
    implementation("com.google.firebase:firebase-analytics")
}

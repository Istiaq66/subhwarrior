plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val kotlinVersion = "1.9.10"
val flutterMinSdk: Int by extra(24)
val flutterTargetSdk: Int by extra(36)
val flutterVersionCode: Int by extra(1)
val flutterVersionName: String by extra("1.0.0")

android {
    namespace = "com.subhwarrior.app"
    compileSdk = rootProject.extra["compileSdkVersion"] as Int
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.subhwarrior.app"
        minSdk = flutterMinSdk
        targetSdk = flutterTargetSdk
        versionCode = flutterVersionCode
        versionName = flutterVersionName

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

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlinVersion")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))
    implementation("com.google.firebase:firebase-analytics")
}

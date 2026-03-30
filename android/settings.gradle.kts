pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
    // 1. Update AGP from 8.7.0 to 8.9.1
    id("com.android.application") version "8.9.1" apply false 
    
    // 2. Update Kotlin from 1.8.22 to 2.1.0 to fix the warning
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false 
    
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
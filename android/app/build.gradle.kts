import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
        android {
            namespace = "com.yourcompany.langbuddy"
            compileSdk = 36
            ndkVersion = "27.0.12077973"

            defaultConfig {
                applicationId = "com.yourcompany.langbuddy"
                minSdk = flutter.minSdkVersion
                targetSdk = 34
                versionCode = 1
                versionName = "1.0.0"
            }

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }

            kotlinOptions {
                jvmTarget = JavaVersion.VERSION_11.toString()
            }

            signingConfigs {
                create("release") {
                    val keystorePropertiesFile = rootProject.file("key.properties")
                    val keystoreProperties = Properties().apply {
                        load(keystorePropertiesFile.inputStream())
                    }

                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }

            buildTypes {
                getByName("release") {
                    signingConfig = signingConfigs.getByName("release")
                    isMinifyEnabled = false
                    isShrinkResources = false
                }
                getByName("debug") {
                    // default debug signing
                }
            }
        }

flutter {
    source = "../.."
}

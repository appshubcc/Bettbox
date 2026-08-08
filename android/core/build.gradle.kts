plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.appshub.bettbox.core"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        minSdk = 26
    }

    buildTypes {
        release {
            isJniDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
dependencies {
    implementation("androidx.annotation:annotation-jvm:1.9.1")
}

val copyNativeLibs by tasks.register<Copy>("copyNativeLibs") {
    val nativeLibsSource = file("../../libclash/android")
    doFirst {
        check(nativeLibsSource.isDirectory && nativeLibsSource.walkTopDown().any {
            it.isFile && it.name == "libclash.so"
        }) {
            "Android core library is missing. Generate libclash before packaging the APK."
        }
        delete("src/main/jniLibs")
    }
    from(nativeLibsSource)
    into("src/main/jniLibs")
}

afterEvaluate {
    tasks.named("preBuild") {
        dependsOn(copyNativeLibs)
    }
}

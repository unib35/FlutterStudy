allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

buildscript {
    repositories {
        google()  // 👈 이 줄이 있어야 Firebase를 찾을 수 있음
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.10") // Firebase 서비스 플러그인 추가
    }
}



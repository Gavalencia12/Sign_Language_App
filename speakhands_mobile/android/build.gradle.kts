buildscript {
    repositories {
        google()  // Repositorio de Google para plugins
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.0.0")  // Versión de Gradle Plugin para Android
        classpath("com.google.gms:google-services:4.3.3")  // Plugin de Google Services
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

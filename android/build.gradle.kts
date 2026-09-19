allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        val android = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (android != null && android.namespace == null) {
            android.namespace = "dev.isar.${project.name.replace("-", "_")}"
        }
        // Workaround: isar_flutter_libs ships compiled against android-30, but its
        // transitive androidx dependencies (fragment, window, lifecycle, etc.) require
        // compileSdk 34+. Force every Android subproject (plugins included) to compile
        // against a modern SDK so release builds don't fail AAR metadata checks.
        if (android != null) {
            android.compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

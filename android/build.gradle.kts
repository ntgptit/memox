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
    project.evaluationDependsOn(":app")
}
subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = extensions.findByName("android")

        if (androidExtension is com.android.build.gradle.LibraryExtension &&
            androidExtension.namespace == null) {
            androidExtension.namespace = project.group.toString().takeIf {
                it != "unspecified"
            } ?: "com.memox.${project.name.replace('-', '_')}"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

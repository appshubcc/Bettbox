
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://raw.githubusercontent.com/guardianproject/gpmaven/master") }
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
    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "androidx.datastore") {
                    useVersion("1.1.2")
                }
                if (requested.group == "androidx.profileinstaller" && requested.name == "profileinstaller") {
                    useVersion("1.4.1")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

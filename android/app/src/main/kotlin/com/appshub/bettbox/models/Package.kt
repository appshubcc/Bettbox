package com.appshub.bettbox.models

data class Package(
    val packageName: String,
    val label: String,
    val system: Boolean,
    val internet: Boolean,
    val firstInstallTime: Long = 0L,
    val lastUpdateTime: Long = 0L,
)

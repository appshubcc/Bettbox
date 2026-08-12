package com.appshub.bettbox

import android.app.Application
import android.content.Context
import android.os.Build

import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngineGroup

class BettboxApplication : Application() {
    companion object {
        private lateinit var instance: BettboxApplication
        fun getAppContext(): Context = instance.applicationContext
    }

    lateinit var engineGroup: FlutterEngineGroup

    override fun onCreate() {
        super.onCreate()
        instance = this
        FlutterInjector.instance().flutterLoader().startInitialization(this)
        engineGroup = FlutterEngineGroup(this)
    }
}

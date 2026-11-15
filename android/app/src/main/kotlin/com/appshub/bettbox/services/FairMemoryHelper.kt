package com.appshub.bettbox.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Parcel
import android.util.Log

class FairMemoryHelper(private val tag: String) {

    companion object {
        private const val ACTION_TRIM = "itgsa.intent.action.TRIM"
        private const val ACTION_KILL = "itgsa.intent.action.KILL"
        private const val KEY_COMMON = "common"
        private const val KEY_NOTIFY_TYPE = "notifyType"
        private const val KEY_NOTIFY_ID = "notifyId"
        private const val KEY_CALLBACK = "callback"
        private const val TRANSACTION_EXCEPTION_REPLY = IBinder.FIRST_CALL_TRANSACTION
    }

    private var handlerThread: HandlerThread? = null
    private var handler: Handler? = null
    private var receiver: BroadcastReceiver? = null

    fun register(
        context: Context,
        onTrim: () -> Unit,
        onKill: () -> Unit,
    ) {
        if (receiver != null) return
        val thread = HandlerThread("FairMemoryHelper").apply { start() }
        handlerThread = thread
        handler = Handler(thread.looper)
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                if (action != ACTION_TRIM && action != ACTION_KILL) return
                val bundle = intent.getBundleExtra(KEY_COMMON) ?: return
                val notifyType = bundle.getInt(KEY_NOTIFY_TYPE)
                val notifyId = bundle.getInt(KEY_NOTIFY_ID)
                val callback = bundle.getBinder(KEY_CALLBACK) ?: return

                Log.d(tag, "Received Fair Memory action: $action, notifyType: $notifyType, notifyId: $notifyId")

                when (action) {
                    ACTION_TRIM -> onTrim()
                    ACTION_KILL -> onKill()
                }
                reply(notifyType, notifyId, 0, callback)
            }
        }
        val filter = IntentFilter().apply {
            addAction(ACTION_TRIM)
            addAction(ACTION_KILL)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, null, handler, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter, null, handler)
        }
    }

    fun unregister(context: Context) {
        receiver?.let {
            runCatching { context.unregisterReceiver(it) }
        }
        receiver = null
        handler = null
        handlerThread?.quitSafely()
        handlerThread = null
    }

    private fun reply(notifyType: Int, notifyId: Int, result: Int, callback: IBinder) {
        val data = Parcel.obtain()
        val reply = Parcel.obtain()
        try {
            data.writeInt(notifyType)
            data.writeInt(notifyId)
            data.writeInt(result)
            data.writeBundle(Bundle())
            callback.transact(TRANSACTION_EXCEPTION_REPLY, data, reply, IBinder.FLAG_ONEWAY)
            reply.readException()
        } catch (e: Exception) {
            Log.e(tag, "reply failed.", e)
        } finally {
            reply.recycle()
            data.recycle()
        }
    }
}

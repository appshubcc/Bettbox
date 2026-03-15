package com.appshub.bettbox.services

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import androidx.lifecycle.Observer
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.R
import com.appshub.bettbox.RunState
import com.appshub.bettbox.TempActivity


@RequiresApi(Build.VERSION_CODES.N)
class BettboxTileService : TileService() {

    private val observer = Observer<RunState> { runState ->
        updateTile(runState)
    }

    private fun updateTile(runState: RunState) {
        if (qsTile != null) {
            qsTile.state = when (runState) {
                RunState.START -> Tile.STATE_ACTIVE
                RunState.PENDING -> Tile.STATE_UNAVAILABLE
                RunState.STOP -> Tile.STATE_INACTIVE
            }
            
            val iconRes = if (runState == RunState.STOP && GlobalState.isSmartStopped) {
                R.drawable.ic_tile_smart_stopped
            } else {
                R.drawable.ic_tile
            }
            qsTile.icon = Icon.createWithResource(this, iconRes)
            
            qsTile.updateTile()
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        GlobalState.syncStatus()
        updateTile(GlobalState.currentRunState)
        GlobalState.runState.observeForever(observer)
    }



    override fun onClick() {
        super.onClick()
        if (isLocked) {
            unlockAndRun {
                GlobalState.handleToggle()
            }
        } else {
            GlobalState.handleToggle()
        }
    }
    
    override fun onTileAdded() {
        super.onTileAdded()
    }
    
    override fun onTileRemoved() {
        super.onTileRemoved()
    }

    override fun onDestroy() {
        GlobalState.runState.removeObserver(observer)
        super.onDestroy()
    }
}
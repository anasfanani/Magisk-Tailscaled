package com.tailscale.magisk

import android.app.AlertDialog
import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.widget.Toast

class TailscaleTileService : TileService() {
    
    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }
    
    override fun onClick() {
        super.onClick()
        showDialog()
    }
    
    private fun showDialog() {
        val dialog = AlertDialog.Builder(this)
            .setTitle("Tailscale")
            .setItems(arrayOf("Connect", "Disconnect", "Restart", "Open App")) { _, which ->
                when (which) {
                    0 -> executeCommand("up")
                    1 -> executeCommand("down")
                    2 -> {
                        executeCommand("down")
                        Thread.sleep(1000)
                        executeCommand("up")
                    }
                    3 -> {
                        val intent = Intent(this, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                    }
                }
            }
            .setNegativeButton("Cancel", null)
            .create()
        
        showDialog(dialog)
    }
    
    private fun executeCommand(action: String) {
        val result = ShellExecutor.exec("tailscale $action")
        if (result.contains("error")) {
            showToast("Failed: $result")
        } else {
            showToast("Tailscale $action")
        }
        Thread.sleep(500)
        updateTile()
    }
    
    private fun checkStatus(): Boolean {
        val output = ShellExecutor.exec("tailscale status 2>/dev/null")
        return output.isNotEmpty() && !output.contains("Stopped")
    }
    
    private fun updateTile() {
        qsTile?.apply {
            state = if (checkStatus()) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
            label = "Tailscale"
            updateTile()
        }
    }
    
    private fun showToast(message: String) {
        Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
    }
}

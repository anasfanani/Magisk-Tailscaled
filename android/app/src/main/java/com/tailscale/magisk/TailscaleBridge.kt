package com.tailscale.magisk

import android.webkit.JavascriptInterface
import kotlinx.coroutines.runBlocking

class TailscaleBridge {
    
    @JavascriptInterface
    fun exec(command: String): String {
        return runBlocking {
            ShellExecutor.exec(command)
        }
    }
    
    @JavascriptInterface
    fun isModuleInstalled(): Boolean {
        val result = ShellExecutor.exec("[ -d /data/adb/modules/magisk-tailscaled ] && echo 1 || echo 0")
        return result.trim() == "1"
    }
    
    @JavascriptInterface
    fun getModulePath(): String {
        return "/data/adb/modules/magisk-tailscaled"
    }
}

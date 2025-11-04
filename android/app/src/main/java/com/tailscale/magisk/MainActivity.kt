package com.tailscale.magisk

import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebChromeClient
import android.webkit.ConsoleMessage
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AppCompatActivity() {
    private lateinit var webView: WebView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable WebView debugging
        WebView.setWebContentsDebuggingEnabled(true)
        
        webView = WebView(this).apply {
            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                allowFileAccess = true
                allowFileAccessFromFileURLs = true
                allowUniversalAccessFromFileURLs = true
            }
            
            // Log console messages
            webChromeClient = object : WebChromeClient() {
                override fun onConsoleMessage(msg: ConsoleMessage): Boolean {
                    Log.d("WebView", "${msg.message()} -- From line ${msg.lineNumber()} of ${msg.sourceId()}")
                    return true
                }
            }
            
            addJavascriptInterface(TailscaleBridge(), "Android")
        }
        
        setContentView(webView)
        
        // Check root access on startup
        checkRootAccess()
    }
    
    private fun checkRootAccess() {
        CoroutineScope(Dispatchers.IO).launch {
            val hasRoot = ShellExecutor.checkRoot()
            
            withContext(Dispatchers.Main) {
                if (hasRoot) {
                    webView.loadUrl("file:///android_asset/webui/index.html")
                } else {
                    Toast.makeText(
                        this@MainActivity,
                        "Root access denied. Please grant root permission.",
                        Toast.LENGTH_LONG
                    ).show()
                    finish()
                }
            }
        }
    }
}

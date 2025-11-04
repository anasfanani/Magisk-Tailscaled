package com.tailscale.magisk

import java.io.BufferedReader
import java.io.InputStreamReader

object ShellExecutor {
    fun checkRoot(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readText()
            process.waitFor()
            output.contains("uid=0")
        } catch (e: Exception) {
            false
        }
    }
    
    fun exec(command: String): String {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "sh -c '$command'"))
            val stdout = BufferedReader(InputStreamReader(process.inputStream)).readText()
            val stderr = BufferedReader(InputStreamReader(process.errorStream)).readText()
            val exitCode = process.waitFor()
            
            // Build output with exit code
            val result = StringBuilder()
            if (stdout.isNotEmpty()) {
                result.append(stdout)
            }
            if (stderr.isNotEmpty()) {
                if (result.isNotEmpty()) result.append("\n")
                result.append("STDERR: $stderr")
            }
            if (exitCode != 0) {
                if (result.isNotEmpty()) result.append("\n")
                result.append("EXIT_CODE: $exitCode")
            }
            
            result.toString().ifEmpty { "EXIT_CODE: $exitCode" }
        } catch (e: Exception) {
            "ERROR: ${e.message}"
        }
    }
}

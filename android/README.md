# Tailscale Magisk Android APK

Companion Android app for Magisk-Tailscaled module.

## Features

- WebView-based UI using shared webroot
- Quick Settings tile for quick toggle
- Root shell integration
- Module status checking

## Requirements

- Android 7.0+ (API 24+)
- Root access (Magisk/KernelSU)
- Magisk-Tailscaled module installed

## Building

```bash
# Build APK
./build-apk.sh

# Or manually:
cd ../webui && npm run build
cd ../android && ./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

## Installation

1. Install Magisk-Tailscaled module first
2. Install APK
3. Grant root permission when prompted
4. Add Quick Settings tile (optional)

## Architecture

- **MainActivity**: WebView host loading webroot
- **TailscaleBridge**: JavaScript ↔ Kotlin bridge
- **ShellExecutor**: Root shell command execution
- **TailscaleTileService**: Quick Settings tile

## Communication

WebUI detects environment and uses appropriate API:

```typescript
// In Android APK
window.Android.exec('tailscale status')

// In KSUWebUI
import { exec } from 'kernelsu'
```

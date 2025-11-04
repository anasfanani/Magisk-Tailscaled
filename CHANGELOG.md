## v2.0.0.1

- 429e1b0 build: fix version bump and add pre-release for build version
- 75834b4 fix: path order

## v2.0.0.0

### ⚠️ Important Notice
This build may be unstable. Please test thoroughly and report any issues you encounter.

**Exit Node Warning**: Using exit nodes may cause battery drain. Not recommended for 24/7 use.

**Testing Your Connection**:
- Check IP: https://browserleaks.com/ip
- Check DNS leaks: https://browserleaks.com/dns

### Major Rewrite
This is a complete rewrite of the module with significant improvements.

### What's New
- **Better DNS handling** - Improved DNS configuration and compatibility
- **SSH support** - Enhanced SSH functionality
- **Exit node support** - Better exit node handling
- **Hotspot client support** - Works with Android hotspot clients
- **VPN compatibility** - Can now run alongside other VPN apps
- **Root & Non-root mode** - Works in both root and non-root environments

### Technical Changes
- Removed all wrapper scripts for better performance
- Now uses tailscaled binaries from [tailscale-android-cli](https://github.com/anasfanani/tailscale-android-cli)
- Simplified module structure
- Improved stability and reliability

### Breaking Changes
This is a major version update. Please backup your configuration before upgrading.

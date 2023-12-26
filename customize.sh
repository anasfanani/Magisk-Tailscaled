case $ARCH in
    arm)   F_ARCH=$ARCH;;
    arm64)   F_ARCH=$ARCH;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
esac

ui_print "- Detected architecture: $F_ARCH"
ui_print "- Copying module files"

CUSTOM_DIR="/data/adb/tailscale"
CUSTOM_BIN_DIR="$CUSTOM_DIR/bin"
CUSTOM_TMP_DIR="$CUSTOM_DIR/tmp"

mkdir -p "$CUSTOM_DIR" "$CUSTOM_BIN_DIR" "$CUSTOM_TMP_DIR"

cp "$MODPATH/tailscale/"* "$CUSTOM_DIR"
cp "$MODPATH/files/tailscaled-$F_ARCH" "$CUSTOM_BIN_DIR/tailscaled"
cp "$MODPATH/files/tailscale-$F_ARCH" "$CUSTOM_BIN_DIR/tailscale"

ui_print "- Setting permissions"

# I wont hardcode the binary names here, because I will add other binaries in the future

set_perm_recursive $CUSTOM_BIN_DIR 0 0 0755 0755
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755 

if [ -f "/data/local/tmp/tailscaled.state" ]; then
    ui_print "- Moving existing state file"
    cp "/data/local/tmp/tailscaled.state" "$CUSTOM_TMP_DIR/tailscaled.state"
    rm -f /data/local/tmp/tailscale* # cleanup old files
fi

ui_print "- Cleaning up"
rm -r "$MODPATH/files"
rm -r "$MODPATH/tailscale"

ui_print "*******************"
ui_print " Instructions       "
ui_print "*******************"
ui_print "1. Reboot your device."
ui_print "2. Run 'su' to gain root access."
ui_print "3. Run 'tailscale login' to login to your Tailscale account."
ui_print "4. Open url in browser to authorize your device."
ui_print "5. Run 'tailscale status' to check Tailscale connection."
ui_print "*******************"
ui_print " Troubleshooting    "
ui_print "*******************"
ui_print "1. Check logs in /data/adb/tailscale/tmp/tailscaled.log."
ui_print "2. Read the docs."
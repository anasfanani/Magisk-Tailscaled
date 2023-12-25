case $ARCH in
    arm)   F_ARCH=$ARCH;;
    arm64)   F_ARCH=$ARCH;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
esac

ui_print "- Detected architecture: $F_ARCH"
ui_print "- Copying module files"

L_TARGETDIR="/data/adb/tailscale"
F_TARGETDIR="/data/adb/tailscale/bin"

mkdir -p "$F_TARGETDIR" "$L_TARGETDIR"

cp "$MODPATH/tailscale/"* "$L_TARGETDIR"
cp "$MODPATH/files/tailscaled-$F_ARCH" "$F_TARGETDIR/tailscaled"
cp "$MODPATH/files/tailscale-$F_ARCH" "$F_TARGETDIR/tailscale"

ui_print "- Setting permissions"

# I wont hardcode the binary names here, because I will add other binaries in the future
# https://github.com/Magisk-Modules-Alt-Repo/submission/issues/209#issuecomment-1865039482

set_perm_recursive $F_TARGETDIR 0 0 0755 0755
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755 

if [ -f "/data/local/tmp/tailscaled.state" ]; then
    ui_print "- Moving existing state file"
    cp "/data/local/tmp/tailscaled.state" "$L_TARGETDIR/tmp/tailscaled.state"
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
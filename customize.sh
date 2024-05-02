#!/system/bin/sh
SKIPUNZIP=1
SKIPMOUNT=false

if [ "$BOOTMODE" != true ]; then
  ui_print "! Please install in Magisk Manager or KernelSU Manager"
  ui_print "! Install from recovery is NOT supported"
  abort "-----------------------------------------------------------"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "error: Please update your KernelSU and KernelSU Manager"
fi

SERVICE_DIR="/data/adb/service.d"

CUSTOM_DIR="/data/adb/tailscale"
CUSTOM_BIN_DIR="$CUSTOM_DIR/bin"
CUSTOM_SCRIPTS_DIR="$CUSTOM_DIR/scripts"
CUSTOM_TMP_DIR="$CUSTOM_DIR/tmp"

case $ARCH in
    arm)   F_ARCH=$ARCH;;
    arm64)   F_ARCH=$ARCH;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
esac
ui_print "- Detected architecture: $F_ARCH"

ui_print "- Extracting module files"
unzip -qqo "$ZIPFILE" -x 'META-INF/*' 'tailscale/*' 'files/*' -d "$MODPATH"

if [ -d "$CUSTOM_DIR" ]; then
    ui_print "- Cleaning up old files"
    for dir in "$CUSTOM_DIR/*"; do
        if [ "$(basename "$dir")" != "tmp" ]; then
            rm -rf "$dir"
        fi
    done
fi

ui_print "- Creating directories"
mkdir -p "$CUSTOM_DIR" "$CUSTOM_BIN_DIR" "$CUSTOM_TMP_DIR" "$CUSTOM_SCRIPTS_DIR" "$SERVICE_DIR"

ui_print "- Extracting scripts"
unzip -qqjo "$ZIPFILE" 'tailscale/bin/*' -d "$CUSTOM_BIN_DIR"
unzip -qqjo "$ZIPFILE" 'tailscale/scripts/*' -d "$CUSTOM_SCRIPTS_DIR"
unzip -qqjo "$ZIPFILE" 'tailscale/settings.ini' -d "$CUSTOM_DIR"

ui_print "- Extracting binaries"
unzip -qqjo "$ZIPFILE" "files/tailscaled-$F_ARCH" -d "$TMPDIR"
unzip -qqjo "$ZIPFILE" "files/tailscale-$F_ARCH" -d "$TMPDIR"
mv -f "$TMPDIR/tailscaled-$F_ARCH" "$CUSTOM_BIN_DIR/tailscaled"
mv -f "$TMPDIR/tailscale-$F_ARCH" "$CUSTOM_BIN_DIR/tailscale"

ui_print "- Setting permissions"
set_perm_recursive $CUSTOM_BIN_DIR 0 0 0755 0755
set_perm_recursive $CUSTOM_SCRIPTS_DIR 0 0 0755 0755
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
set_perm $MODPATH/service.sh 0 0 0755

if [ ! -f "$SERVICE_DIR/tailscaled_service.sh" ]; then
    # offer to move module scripts to general scripts
    ui_print "-----------------------------------------------------------"
    ui_print "- Do you want to move Module Scripts to General Scripts ?"
    ui_print "- This option allows you to toggle the 'tailscaled' service"
    ui_print "  on or off by enabling or disabling modules."
    ui_print "- Your service directory is :"
    ui_print "  '$SERVICE_DIR'."
    ui_print "- Because the Developer Guides mentioned :"
    ui_print "  Modules should NOT add general scripts during installation."
    ui_print "- I offer this option to you."
    ui_print "- You have 30 seconds to make a selection. Default is [Yes]."
    ui_print "- [ Vol UP(+): Yes ]"
    ui_print "- [ Vol DOWN(-): No ]"
    start_time=`date +%s`
    while true; do
      current_time=`date +%s`
      time_diff=`expr $current_time - $start_time`
      if [ $time_diff -ge 30 ]; then
        ui_print "- Time's up! Proceeding with default option [Yes]."
        ui_print "- Move Module Scripts to General Scripts."
        mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
        break
      fi
      getevent -lc 1 2>&1 | grep KEY_VOLUME > $TMPDIR/events
      if $(cat $TMPDIR/events | grep -q KEY_VOLUMEUP) ; then
        ui_print "- [Yes] Move Module Scripts to General Scripts."
        mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
        break
      elif $(cat $TMPDIR/events | grep -q KEY_VOLUMEDOWN) ; then
        ui_print "- [No] Skip and keep using Module Scripts."
        break
      fi
    done
else
    ui_print "- Move General Scripts."
    mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
fi

ui_print "-----------------------------------------------------------"
ui_print " Instructions       "
ui_print "-----------------------------------------------------------"
ui_print "- Reboot your device."
ui_print "- Start Tailscale service :"
ui_print "  su -c 'tailscaled.service start'"
ui_print "- Login to your Tailscale account :"
ui_print "  su -c 'tailscale login'"
ui_print "- Logs :"
ui_print "  '$CUSTOM_DIR/run/'"
#!/system/bin/sh

# Github download helper
gh_download(){
  REPO=$1
  MATCH=$2
  DOWNLOAD_URL=$(
    wget --no-check-certificate -qO- "https://api.github.com/repos/${REPO}/releases/latest" | \
    grep "browser_download_url" | \
    grep "${MATCH}" | \
    sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' \
    || true \
  )
  if [ -z "$DOWNLOAD_URL" ]; then
    ui_print "! Unable to get release from https://github.com/${REPO}/releases"
    return 1
  fi
  FILENAME=$(basename "$DOWNLOAD_URL")
  ui_print "- Downloading $FILENAME..."
  wget --no-check-certificate -qO "$TMPDIR/$FILENAME" "$DOWNLOAD_URL"
}

# shellcheck disable=SC2034
SKIPUNZIP=1
# shellcheck disable=SC2034
SKIPMOUNT=false

if [ "$BOOTMODE" != true ]; then
  ui_print "! Please install in Magisk Manager or KernelSU Manager"
  ui_print "! Install from recovery is NOT supported"
  abort "-----------------------------------------------------------"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "error: Please update your KernelSU and KernelSU Manager"
fi

SERVICE_DIR="/data/adb/service.d"

TS_DIR="/data/adb/tailscale"
TS_BIN_DIR="$TS_DIR/bin"
TS_SCRIPTS_DIR="$TS_DIR/scripts"

case $ARCH in
    arm)   F_ARCH="armv7a";;
    arm64)   F_ARCH="aarch64";;
    *)     ui_print "Unsupported architecture: $ARCH"; abort;;
esac
ui_print "- Detected architecture: $ARCH"

if [ -d "$TS_DIR" ]; then
    ui_print "- Cleaning up old files"
    for p in "$TS_DIR"/* "$TS_DIR"/.??*; do
      case "$p" in
        "$TS_DIR"/tailscaled.state|"$TS_DIR"/ssh|"$TS_DIR"/certs) ;;
        *) echo rm -rf -- "$p" ;;
      esac
    done
fi


mkdir -p $TS_BIN_DIR
if gh_download "anasfanani/tailscale-android-cli" "tailscale_.*_${ARCH}\.tgz"; then
  tar -xzf "$TMPDIR/$FILENAME" -C $TS_BIN_DIR || abort "error: Unable extract archive."
else
  abort "error: Unable to download."
fi

if gh_download "theshoqanebi/jq-build-for-android" "jq-${F_ARCH}-linux-android"; then
  mv -f "$TMPDIR/$FILENAME" "$TS_BIN_DIR/jq" || abort "error: Unable to move file."
else
  abort "error: Unable to download."
fi

ui_print "- Extracting files..."
unzip -qqo "$ZIPFILE" -x 'META-INF/*' 'tailscale/*' -d "$MODPATH"



mkdir -p "$TS_DIR" "$TS_SCRIPTS_DIR" "$SERVICE_DIR" "$MODPATH/system/bin/"
unzip -qqjo "$ZIPFILE" 'tailscale/scripts/*' -d "$TS_SCRIPTS_DIR"
unzip -qqjo "$ZIPFILE" 'tailscale/settings.sh' -d "$TS_DIR"
ln -sf "$TS_BIN_DIR/tailscaled" "$TS_BIN_DIR/tailscale"
ln -sf "$TS_BIN_DIR/tailscaled" "$MODPATH/system/bin/tailscale"

ui_print "- Setting permissions"
set_perm_recursive "$TS_BIN_DIR" 0 0 0755 0755
set_perm_recursive "$TS_SCRIPTS_DIR" 0 0 0755 0755
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
set_perm "$MODPATH/service.sh" 0 0 0755

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
    ui_print "- You have 10 seconds to make a selection. Default is [Yes]."
    ui_print "- [ Vol UP(+): Yes ]"
    ui_print "- [ Vol DOWN(-): No ]"
    START_TIME=$(date +%s)
    while true; do
      CURRENT_TIME=$(date +%s)
      time_diff=$(("$CURRENT_TIME" - "$START_TIME"))
      if [ "$time_diff" -ge 10 ]; then
        ui_print "- Time's up! Proceeding with default option [Yes]."
        ui_print "- Move Module Scripts to General Scripts."
        mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
        break
      fi
      getevent -lc 1 2>&1 | grep KEY_VOLUME > "$TMPDIR"/events
      if cat "$TMPDIR"/events | grep -q KEY_VOLUMEUP > /dev/null 2>&1; then
        ui_print "- [Yes] Move Module Scripts to General Scripts."
        mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
        break
      elif cat "$TMPDIR"/events | grep -q KEY_VOLUMEDOWN > /dev/null 2>&1; then
        ui_print "- [No] Skip and keep using Module Scripts."
        break
      fi
    done
else
    ui_print "- Move General Scripts."
    mv -f "$MODPATH/service.sh" "$SERVICE_DIR/tailscaled_service.sh"
fi
ui_print "- Starting service in background."
${TS_SCRIPTS_DIR}/start.sh postinstall 2>&1 &
if [ ! -f "/system/bin/tailscale" ] || ! cmp --silent "/system/bin/tailscale" "$MODPATH/system/bin/tailscale"; then
  ui_print "- Link file to /dev/."
  ln -sf "$TS_SCRIPTS_DIR/tailscaled.service" /dev/tailscaled.service
  ln -sf "$TS_BIN_DIR/tailscaled" /dev/tailscaled
  ln -sf "$TS_BIN_DIR/tailscaled" /dev/tailscale
  ui_print "-----------------------------------------------------------"
  ui_print " Instructions       "
  ui_print "-----------------------------------------------------------"
  ui_print "- If you not reboot, execute with /dev/tailscale or /dev/tailscaled.service."
  ui_print "- After reboot, you can use tailscale and tailscaled.service directly."
  if [ ! -f "$TS_DIR/tailscaled.state" ]; then
    ui_print "- Quickstart to new user :"
    ui_print "  su -c '/dev/tailscale login'"
    ui_print "  su -c '/dev/tailscaled.service status'"
    ui_print "- Read the README.md"
  else
    ui_print "- Tailscaled service manager :"
    ui_print "  su -c '/dev/tailscaled.service'"
  fi
else
  if [ ! -f "$TS_DIR/tailscaled.state" ]; then
    ui_print "- Quickstart to login :"
    ui_print "  su -c 'tailscale login'"
    ui_print "  su -c 'tailscaled.service status'"
    ui_print "- Read the README.md"
  else
    ui_print "- Tailscaled service manager :"
    ui_print "  su -c 'tailscaled.service'"
  fi
fi
#!/system/bin/sh
DIR=$(dirname "$(realpath "$0")")
# shellcheck source=../settings.sh
. "$DIR"/../settings.sh
case "$1" in
    postinstall)
      rm -rf $TS_RUN_DIR && mkdir -p $TS_RUN_DIR
      tailscaled.service restart >> "/dev/null" 2>&1 &
      return 0
    ;;
esac
start_service() {
  if [ ! -f "${MOD_DIR}/disable" ]; then
    tailscaled.service start >> "/dev/null" 2>&1
  fi
}
start_inotifyd() {
  for PID in $(busybox pidof inotifyd); do
    if grep -q "tailscaled.inotify" "/proc/$PID/cmdline"; then
      kill -9 "$PID"
    fi
  done
  echo "${CURRENT_TIME} [Info]: Starting tailscaled inotify service" > "${TS_RUN_LOG_FILE}"
  inotifyd "tailscaled.inotify" "${MOD_DIR}" >> "/dev/null" 2>&1 &
}

module_version=$(busybox awk -F'=' '!/^ *#/ && /version=/ { print $2 }' "$MOD_PROP" 2>/dev/null)
log Info "Magisk Tailscaled version : ${module_version}."
start_service
start_inotifyd
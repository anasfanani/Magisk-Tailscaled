#!/system/bin/sh
DIR=$(dirname $(realpath $0))
source $DIR/../settings.sh
case "$1" in
    postinstall)
      rm -rf $tailscaled_run_dir
      mkdir -p $tailscaled_run_dir
      touch "${tailscale_dir}/tmp/resolv.conf"
      chown -R root:net_bt_admin "${tailscale_dir}/bin/"
      $tailscaled_service restart >> "/dev/null" 2>&1 &
      return 0
    ;;
esac
start_service() {
  if [ ! -f "${module_dir}/disable" ]; then
    $tailscaled_service start >> "/dev/null" 2>&1
  fi
}
start_inotifyd() {
  PIDs=($(busybox pidof inotifyd))
  for PID in "${PIDs[@]}"; do
    if grep -q "${tailscaled_inotify}" "/proc/$PID/cmdline"; then
      kill -9 "$PID"
    fi
  done
  echo "${current_time} [Info]: Starting tailscaled inotify service" > "${tailscaled_runs_log}"
  inotifyd "${tailscaled_inotify}" "${module_dir}" >> "/dev/null" 2>&1 &
}

module_version=$(busybox awk -F'=' '!/^ *#/ && /version=/ { print $2 }' "$module_prop" 2>/dev/null)
log Info "Magisk Tailscaled version : ${module_version}."
start_service
# start_socks5tunnel # no longer run automatically at boot, because ndk build work, except you're using verry obsoleted android device
start_inotifyd
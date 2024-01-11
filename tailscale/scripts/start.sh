#!/system/bin/sh
DIR=${0%/*}
source $DIR/../settings.ini

stop_service() {
  if [ -f "${tailscaled_run_dir}/tailscaled.pid" ]; then
    "${tailscaled_service}" stop >> "/dev/null" 2>&1
  fi
}
start_service() {
  if [ ! -f "${module_dir}/disable" ]; then
    "${tailscaled_service}" start >> "/dev/null" 2>&1
  fi
}
start_inotifyd() {
  PIDs=($(busybox pidof inotifyd))
  for PID in "${PIDs[@]}"; do
    if grep -q "${tailscaled_inotify}" "/proc/$PID/cmdline"; then
      kill -9 "$PID"
    fi
  done
  echo "${current_time} [Info]: Starting tailscaled inotify service" > "${tailscaled_service_log}"
  inotifyd "${tailscaled_inotify}" "${module_dir}" >> "/dev/null" 2>&1 &
}
mkdir -p ${tailscaled_run_dir}
rm -f ${tailscaled_runs_log}
module_version=$(busybox awk -F'=' '!/^ *#/ && /version=/ { print $2 }' "$module_prop" 2>/dev/null)
log Info "Magisk Tailscaled version : ${module_version}."
start_service
start_inotifyd

#!/system/bin/sh
set -e

# Custom settings

# Take the current time
CURRENT_TIME=$(date +"%I:%M %P")

# Set Magisk Tailscale module variables
MOD_DIR="/data/adb/modules/magisk-tailscaled" # Bad code, if magisk in the future change the path location, need to change this.
export MOD_PROP="${MOD_DIR}/module.prop"

# Set tailscale directory variables
TS_DIR="/data/adb/tailscale"

# Set path environment for busybox & other.
export PATH="/data/adb/magisk:/data/adb/ksu/bin:$PATH:/system/bin:${MOD_DIR}/system/bin:${TS_DIR}/bin:${TS_DIR}/scripts"
export HOME="/data/adb/tailscale/" # Because tailscaled will write log to $HOME

# Set tailscaled & tailscale configuration
export TS_DAEMON_CMD="tailscaled -no-logs-no-support"
export TS_SSH=true

# Set tailscaled directory variables
export TS_RUN_DIR="${TS_DIR}/run"

# Set tailscaled log variables
export TS_LOG_FILE="${TS_RUN_DIR}/tailscaled.log"
export TS_RUN_LOG_FILE="${TS_RUN_DIR}/runs.log"

# Coloring
export normal="\033[0m"
export orange="\033[1;38;5;208m"
export red="\033[1;31m"
export green="\033[1;32m"
export yellow="\033[1;33m"
export blue="\033[1;34m"
export white="\033[97m"

# Logs function
log() {
  # Selects the text color according to the parameters
  case $1 in
  Info) color="${blue}" ;;
  Error) color="${red}" ;;
  Warning) color="${yellow}" ;;
  Debug) color="${orange}" ;;
  *) color="${normal}" ;;
  esac
  # Add messages to time and parameters
  message="${CURRENT_TIME} [$1]: $2"
  if [ -z "$color" ]; then
    echo "${CURRENT_TIME} [Debug]: $1 $2" >>${TS_RUN_LOG_FILE} 2>&1
    return
  fi
  if [ -t 1 ]; then
    # Prints messages to the console
    echo "${color}${message}${normal}"
    echo "${message}" >>${TS_RUN_LOG_FILE} 2>&1
  else
    # Print messages to a log file
    echo "${message}" >>${TS_RUN_LOG_FILE} 2>&1
  fi
}

[ ! -z "$DEBUG" ] && set -u && set -x && PS4='+ ${0##*/}:${LINENO}: ' || true
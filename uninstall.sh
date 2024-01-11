rm -rf /data/adb/tailscale
SERVICE_DIR="/data/adb/service.d"
if [ "$KSU" = true ]; then
  SERVICE_DIR="/data/adb/ksu/service.d"
fi
if [ -f "$SERVICE_DIR/tailscaled_service.sh" ]; then
    rm -f "$SERVICE_DIR/tailscaled_service.sh"
fi
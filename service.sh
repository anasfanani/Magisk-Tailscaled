# wait for boot to complete
while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done
# wait for network to be available
echo "Waiting network to be available">/data/local/tmp/tailscaled.log
while true; do
    curl -Is 1.1.1.1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    else
        sleep 2
    fi
done
# ensure boot & network has actually completed
sleep 5
# start tailscaled
echo "Starting tailscaled">>/data/local/tmp/tailscaled.log
while true;do
    # https://github.com/tailscale/tailscale/issues?q=no+safe+place+found+to+store+log+state
    cd /data/local/tmp/ && tailscaled -tun=userspace-networking -statedir=/data/local/tmp/ -state=/data/local/tmp/tailscaled.state --port=41641 >> /data/local/tmp/tailscaled.log 2>&1
    sleep 5
    echo "Tailscaled restarting">>/data/local/tmp/tailscaled.log
done
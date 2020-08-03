#!/usr/bin/env bash
set -eu

# fix user id if needed
usermod --uid "$USER_ID" --gid "$GROUP_ID" pulse

# prepare log file and fix ownership
mkdir -p /data/.pulse_secure/pulse
touch /data/.pulse_secure/pulse/pulsesvc.log
chown -R "$USER_ID:$GROUP_ID" /data

tail -f /data/.pulse_secure/pulse/pulsesvc.log | while read -r line; do
    # cut off first two blocks of the log message
    line="${line#* * }"
    echo "${line}"
    # keep the tunnel open by sending a ping message every 5 min to the gateway
    if [[ "${line}" =~ ^adapter.info\ cip\ =\ [^,]+,\ mask\ =\ [^,]+,\ gw\ =\ ([^,]+), ]]; then
        ping -i 300 -- "${BASH_REMATCH[1]}" | while read -r line; do
            echo "keepalive.info ${line}"
        done &
    fi
done &

# docker always bind mounts /etc/hosts, but pulse insists in moving this file
# container must have CAP_SYS_ADMIN otherwise unmount will fail
if mountpoint -q /etc/hosts; then
    cp /etc/hosts /etc/hosts.bak
    umount /etc/hosts
    mv /etc/hosts.bak /etc/hosts
fi

exec su -c /usr/local/pulse/pulseUi pulse


#!/usr/bin/env bash
set -eu

USER_ID="${USER_ID:-1000}"
GROUP_ID="${GROUP_ID:-$USER_ID}"

# create user with same uid and gid as outside the container
getent group pulse &> /dev/null || groupadd --gid "$GROUP_ID" pulse
getent passwd pulse &> /dev/null || useradd --uid "$USER_ID" --gid "$GROUP_ID" --comment pulse --home-dir /data --no-create-home pulse

# fix ownership
mkdir -p /data/.pulse_secure/pulse
touch /data/.pulse_secure/pulse/pulsesvc.log /data/.pulse_secure/pulse/.pulse_Connections.txt
chown -R "$USER_ID:$GROUP_ID" /data

# docker always bind mounts /etc/hosts, but pulse insists in moving this file
# container must run in privileged mode otherwise unmount will fail
if mountpoint -q /etc/hosts; then
    cp /etc/hosts /tmp/
    umount /etc/hosts
    mv /tmp/hosts /etc/
fi

cd /data
exec su -c /pulse-wrapper.sh pulse


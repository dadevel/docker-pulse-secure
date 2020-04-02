#!/bin/sh
set -eu

USER_ID="${USER_ID:-1000}"
GROUP_ID="${GROUP_ID:-$USER_ID}"

# create user with same uid and gid as outside the container
getent group "$GROUP_ID" &> /dev/null || addgroup -g "$GROUP_ID" proxy
getent passwd "$USER_ID" &> /dev/null || adduser -u "$USER_ID" -g proxy -G proxy -D -h /data -H proxy

# fix ownership and permissions
mkdir -p /data/.ssh
chmod 700 /data/.ssh
touch /data/.ssh/authorized_keys
chmod 600 /data/.ssh/authorized_keys
chown -R "$USER_ID:$GROUP_ID" /data

# set random password, user must be enabled to allow ssh login
echo "proxy:$(tr -dc [:alnum:] < /dev/urandom | head -c 32)" | chpasswd

exec /usr/sbin/sshd -D -e "$@"


FROM docker.io/library/ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

# install pulse
# lsb-release is required by the install script of the pulse package
# iputils-ping is used in entrypoint.sh to keep the tunnel alive
# all other packages are dependencies of pulse secure, extracted from UBUNTU_16_17_18_DEPENDENCIES_WITH_VERSION in /usr/local/pulse/PulseClient_x86_64.sh
COPY ./pulse.deb .
RUN apt-get update && \
apt-get install --no-install-recommends -y lsb-release iputils-ping ca-certificates iproute2 libc6 libwebkitgtk-1.0-0 libproxy1v5 libproxy1-plugin-gsettings libproxy1-plugin-webkit libdconf1 libgnome-keyring0 dconf-gsettings-backend && \
dpkg -i ./pulse.deb && \
rm ./pulse.deb && \
apt-get purge --autoremove -y lsb-release

# pulse wants to modify firewall rules and kernel parameters in order to disable ipv6, which is not only unnecessary but also not possible for an unprivileged container, so we replace it with a no-op
RUN ln -sf /bin/true /sbin/ip6tables && \
ln -sf /bin/true /sbin/sysctl

# add user
ENV USER_ID 1000
ENV GROUP_ID 1000
RUN groupadd --gid $GROUP_ID pulse && \
useradd --uid $USER_ID --gid $GROUP_ID --comment pulse --home-dir /data --no-create-home pulse

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /data

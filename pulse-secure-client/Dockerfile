FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# populate package database
RUN apt-get update

# install pulse
# lsb-release is required by the install script of the pulse package
# iputils-ping is used by pulse-wrapper.sh
# all other packages are dependencies of pulse secure, libraries were extracted from UBUNTU_16_17_18_DEPENDENCIES_WITH_VERSION in /usr/local/pulse/PulseClient_x86_64.sh
COPY ./pulse.deb .
RUN apt-get install --no-install-recommends -y lsb-release iputils-ping ca-certificates iproute2 libc6 libwebkitgtk-1.0-0 libproxy1v5 libproxy1-plugin-gsettings libproxy1-plugin-webkit libdconf1 libgnome-keyring0 dconf-gsettings-backend && \
dpkg -i ./pulse.deb && \
rm ./pulse.deb && \
apt-get purge --autoremove -y lsb-release

# pulse wants to modify firewall rules and kernel parameters in order to disable ipv6, which is not only unnecessary but also not possible for an unprivileged container, so we replace it with a no-op
RUN ln -sf /bin/true /sbin/ip6tables && \
ln -sf /bin/true /sbin/sysctl

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR ["/data"]
VOLUME ["/data"]


FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# populate package database
RUN apt-get update

# install pulse
# the required libraries are extracted from UBUNTU_16_17_18_DEPENDENCIES_WITH_VERSION in /usr/local/pulse/PulseClient_x86_64.sh
# lsb-release is required by the install script of the pulse package
COPY ./pulse.deb .
RUN apt-get install --no-install-recommends -y lsb-release ca-certificates iproute2 libc6 libwebkitgtk-1.0-0 libproxy1v5 libproxy1-plugin-gsettings libproxy1-plugin-webkit libdconf1 libgnome-keyring0 dconf-gsettings-backend && \
dpkg -i ./ps-pulse-linux-9.1r4.0-b143-ubuntu-debian-64-bit-installer.deb && \
rm ./ps-pulse-linux-9.1r4.0-b143-ubuntu-debian-64-bit-installer.deb && \
apt-get purge --autoremove -y lsb-release

# pulse wants to modify firewall rules and kernel parameters in order to disable ipv6, which is not only unnecessary but also not possible for an unprivileged container, so we replace it with a no-op
RUN rm -f /sbin/ip6tables /sbin/sysctl && \
ln -s /bin/true /sbin/ip6tables && \
ln -s /bin/true /sbin/sysctl

COPY ./entrypoint.sh /pulse-wrapper.sh /
ENTRYPOINT ["/entrypoint.sh"]
VOLUME ["/data"]


FROM alpine:latest

# install sshd
RUN apk add --no-cache openssh-server

# generate host keys
RUN ssh-keygen -A

# configure sshd
COPY ./sshd_config /etc/ssh/

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR ["/data"]
VOLUME ["/data"]


FROM docker.io/library/alpine:latest
RUN apk add --no-cache openssh-server openssh-sftp-server && \
ssh-keygen -A && \
addgroup -g 1000 proxy && \
adduser -u 1000 -g proxy -G proxy -D -h / -H proxy && \
echo proxy: | chpasswd
COPY ./sshd_config /etc/ssh/
ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]

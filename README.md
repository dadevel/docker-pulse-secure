# docker-pulse-secure [![CI](https://github.com/dadevel/docker-pulse-secure/workflows/CI/badge.svg?branch=master)](https://github.com/dadevel/docker-pulse-secure/actions) [![Docker Image Version (latest by date)](https://img.shields.io/docker/v/dadevel/pulse-secure-client?color=blue&logo=docker)](https://hub.docker.com/r/dadevel/pulse-secure-client)

Make a Pulse Secure VPN available as SSH jumphost and SOCKS5 proxy.

**Note:** This is merely a last resort if [openconncet](https://gitlab.com/openconnect/openconnect) and [openconnect-sso](https://github.com/vlaci/openconnect-sso) don't work for you.

## Usage

Create a Pulse Secure connections file.

`~/.config/pulse-secure/connections.txt`:

~~~ json
{"connName": "Example Inc.", "baseUrl": "https://vpn.example.com", "preferredCert": ""}
{"connName": "My Organization", "baseUrl": "https://gateway.example.org", "preferredCert": ""}
~~~

Start both containers.

~~~ sh
docker run --name pulse-client --detach --device /dev/net/tun --cap-add net_admin --cap-add sys_admin --ip 172.31.255.2 --volume ~/.config/pulse-secure/connections.txt:/data/.pulse_secure/pulse/.pulse_Connections.txt --volume /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY --env "USER_ID=$(id -u)" --env "GROUP_ID=$(id -g)" dadevel/pulse-secure-client:latest
docker run --name pulse-proxy --detach --network container:pulse-client dadevel/openssh-proxy:latest
~~~

Adapt your SSH configuration.

`~/.ssh/config`:

~~~
Host pulse-proxy
  Hostname 172.31.255.2
  User proxy
  DynamicForward 6789
  ForwardAgent yes
  AddKeysToAgent yes

Host gitlab.example.com
  User git
  ProxyJump pulse-proxy
~~~

Git LFS can make use of the proxy established by SSH.

~~~ sh
git config http.proxy socks5://127.0.0.1:6789
git config https.proxy socks5://127.0.0.1:6789
~~~

I recommend [Firefox](https://www.mozilla.org/en-US/firefox/) with [FoxyProxy](https://github.com/foxyproxy/firefox-extension) to view websites trough the proxy.

If your experiencing connection problems check the logs.

~~~ sh
docker logs -f pulse-client
docker logs -f pulse-proxy
~~~

## Build

Pulse Secure mails you a download link to their Debian/Ubuntu package after you filled out [this](https://www.pulsesecure.net/trynow/client-download/) form with some random data.
Once downloaded move the `*.deb` file to `./pulse-secure-client/pulse.deb`.

~~~ sh
docker build -t dadevel/pulse-secure-client ./pulse-secure-client/
docker build -t dadevel/openssh-proxy ./openssh-proxy/
~~~


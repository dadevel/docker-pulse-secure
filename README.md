# docker-pulse-secure

Make a Pulse Secure VPN available as SSH jumphost and SOCKS5 proxy.

**Note:** This is merely a last resort if you can't get [openconncet](https://gitlab.com/openconnect/openconnect) and [openconnect-sso](https://github.com/vlaci/openconnect-sso) working.
You should definitely try them first.

## Build

Place the Debian/Ubuntu package provided by Pulse Secure in `./pulse-secure-client/pulse.deb`.
You get a download link by mail after you filled some random data into this [form](https://www.pulsesecure.net/trynow/client-download/).

~~~ sh
docker build --tag dadevel/openssh-proxy:latest ./openssh-proxy/
docker build --tag dadevel/pulse-secure-client:latest ./pulse-secure-client/
~~~

## Usage

Create a Pulse Secure connections file.

`./connections.txt`:
~~~ json
{"connName": "Example Inc.", "baseUrl": "https://vpn.example.com", "preferredCert": ""}
{"connName": "My Organization", "baseUrl": "https://gateway.example.org", "preferredCert": ""}
~~~

Start both containers.

~~~ sh
docker run --name pulse-client --detach --device /dev/net/tun --cap-add net_admin --cap-add sys_admin --ip=172.31.255.2 --volume "$PWD/connections.txt:/data/.pulse_secure/pulse/.pulse_Connections.txt" --volume /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY --env "USER_ID=$(id -u)" --env "GROUP_ID=$(id -g)" dadevel/pulse-secure-client:latest
docker run --name pulse-proxy --detach --network container:pulse-client --volume ~/.ssh/id_rsa.pub:/data/.ssh/authorized_keys --env "USER_ID=$(id -u)" --env "GROUP_ID=$(id -g)" dadevel/openssh-proxy:latest
~~~

Adapt your SSH configuration.

`~/.ssh/config`:
~~~
Host example-proxy
  Hostname 172.31.255.2
  User proxy
  IdentityFile ~/.ssh/id_rsa
  DynamicForward 6789
  ForwardAgent yes
  AddKeysToAgent yes

Host gitlab.example.com
  User git
  IdentityFile ~/.ssh/id_rsa
  ProxyJump pulse-proxy
~~~

Git LFS can make use of the proxy established by SSH.

~~~ sh
git config http.proxy socks5://127.0.0.1:6789
git config https.proxy socks5://127.0.0.1:6789
~~~

I recommend [Firefox](https://www.mozilla.org/en-US/firefox/) with [FoxyProxy](https://github.com/foxyproxy/firefox-extension) to view websites trough the proxy.

If your experiencing connection problems check docker logs.

~~~ sh
docker logs -f pulse-client
docker logs -f pulse-proxy
~~~


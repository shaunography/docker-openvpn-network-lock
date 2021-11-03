# docker-openvpn-network-lock
Docker based OpenVPN client with UFW based network lock

# usage
## create new docker bridge network
```
docker network create \
    --subnet=172.30.30.0/24 \
    -o com.docker.network.bridge.host_binding_ipv4="172.30.30.1" \
    -o com.docker.network.bridge.name="vpnBridge" \
    vpn
```
the default binding ip is 172.30.30.1 not 0.0.0.0, this allows the same ports to be used across multiple docker networks without clashes and will not expose the port the the wider LAN.

## add openvpn client configuration
add your openvpn.conf file into `./openvpn/<provider>/client.conf` for example `./openvpn/airvpn/client.conf` (conf file must be name client.conf). if you are using username and password authentication create a txt file (userpass.txt) in the same directory (username line 1 password line 2).

It is also recoemened to add the following to your .ovpn file to allow openresolv to configure dns
```
script-security 2 
up /etc/openvpn/update-resolv-conf 
down /etc/openvpn/update-resolv-conf
```

## build image
```
docker build -t vpn .
```

## run vpn container
```
docker run -d \
    --name airvpn \
    --network vpn \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -e LOCAL_IPS="192.168.1.0/24" \
    -e EXPOSED_PORTS="8888/tcp 61618/tcp 61618/udp 8388/tcp 8388/udp 1080/tcp" \
    -e VPN_HOSTNAMES="europe.all.vpn.airdns.org" \
    -e CONFIG="airvpn" \
    -p 8888:8888 \
    -p 8388:8388 \
    -p 8388:8388/udp \
    -p 61618:61618 \
    -p 61618:61618/udp \
    -p 1080:1080 \
    vpn
```
because other containers will be using this containers network interface to access the VPN, any ports that the containers you connect require, need to be specified here. In this example the container will connect to AirVPN and expose ports for Qbittorrent (8888 61618) and a Shadowsocks server (8388 1080).

## enviroment variables
When the vpn container is started the entry point scripts will use the following enviroment variables (passed to docker run with -e) to configure the firewall and vpn.

| var               | default                                   | description                                                         |
|-------------------|-------------------------------------------|---------------------------------------------------------------------|
| LOCAL_IPS         | "192.168.0.0/16 172.16.0.0/12 10.0.0.0/8" | LAN IPs to allow                                                    |
| EXPOSED_PORTS     |                                           | Ports to expose to the external network ( both -e and -p required)  |
| VPN_HOSTNAMES     |                                           | Hostname of vpn server entry point                                  |
| CONFIG            |                                           | name of the VPN provider, needs to match the folder name in openvpn |
| AUTH              |                                           | specfiy "userpass" if username and password auth is being used      |
| VPN_INTERFACES    | "tun+"                                    | name of tunnel interfaces                                           |


## connect to container
If the vpn container is stopped, child containers will lose their network interface and therefore network connectivity.

### Kali Linux
```
docker run -ti --network container:airvpn kalilinux/kali-rolling
```

### Qbittorrent
```
docker run -d \
    --name qbittorrent \
    --network container:airvpn \
    -e PUID=$(id -u) \
    -e PGID=$(id -u) \
    -e TZ=Europe/London \
    -e WEBUI_PORT=8888 \
    -v ~/.qbittorrent:/config \
    --restart unless-stopped \
    -v /media:/media \
    lscr.io/linuxserver/qbittorrent
```
### Shadowsocks server
```
docker run -d \
    --name shadowsocksairvpn \
    --network container:airvpn \
    -e PASSWORD=password \
    shadowsocks/shadowsocks-libev
```
### Shadowsocks client
#### docker
```
docker run -d \
    --name shadowsocksairvpnclient \
    --network container:airvpn \
    shadowsocks/shadowsocks-libev \
    ss-local \
    -k password \
    -p 8388 \
    -s 127.0.0.1 \
    -b 0.0.0.0 \
    -l 1080 \
    -m aes-256-gcm
```
Then point your applications at the socks5 proxy located at `172.30.30.1:1080`
#### locally
```
ss-local -k password -p 8388 -s 172.30.30.1 -l 1080 -m aes-256-gcm
```
Then point your applications at the socks5 proxy located at `127.0.0.1:1080`

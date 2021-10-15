# docker-openvpn-network-lock
Docker based OpenVPN client with UFW based network lock

# usage

## create new docker bridge network
```
docker network create \
    --subnet=172.30.30.0/24 \
    -o com.docker.network.bridge.enable_ip_masquerade=true \
    -o com.docker.network.bridge.host_binding_ipv4="172.30.30.1" \
    -o com.docker.network.bridge.name="vpnBridge" \
    vpn
```
## add openvpn client configuration
add your openvpn.conf file into `./openvpn/<provider>/client.conf` for example `./openvpn/airvpn/client.conf` (conf file must be name client.conf). if you are using username and password authentication create a txt file (userpass.txt) in the same directory (username line 1 password line 2).

## build image
```
docker build -t vpn .
```

## run container
```
docker run -d \
    --name airvpn \
    --network vpn \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -e LOCAL_IPS="192.168.1.0/24" \
    -e EXPOSED_PORTS="8888 61618" \
    -e VPN_HOSTNAMES="europe.all.vpn.airdns.org" \
    -e CONFIG="airvpn" \
    -p 8888:8888 \
    -p 61618:61618 \
    vpn
```
because containers will be using this containers network interface to access the VPN, any ports that the container you connect require (torrent client for example) need to be specified here.

## connect to container (--network container:<name>)
```
docker run -ti --network container:airvpn kalilinux/kali-rolling
```


# enviroment vars
When the container is start the entry point scripts will use the following envrioment variables (passed to docker run with -e) to configure the firewall and vpn.

| var               | defualt                                   | description                                                         |
|-------------------|-------------------------------------------|---------------------------------------------------------------------|
| LOCAL_IPS         | "192.168.0.0/16 172.16.0.0/12 10.0.0.0/8" | LAN IPs to allow                                                    |
| EXPOSED_PORTS     |                                           | Ports to expose to the external network ( both -e and -p required)  |
| VPN_HOSTNAMES     |                                           | Hostname of vpn server entry point                                  |
| CONFIG            |                                           | name of the VPN provider, needs to match the folder name in openvpn |
| AUTH              |                                           | specfiy "userpass" if username and password auth is being used      |
| VPN_INTERFACES    | "tun+"                                    | name of tunnel interfaces                                           |


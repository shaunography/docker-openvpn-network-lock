alias create-airvpn-network='docker network create \
    --subnet=172.30.30.0/24 \
    -o com.docker.network.bridge.enable_ip_masquerade=true \
    -o com.docker.network.bridge.host_binding_ipv4="172.30.30.1" \
    -o com.docker.network.bridge.name="airvpnBridge" \
    airvpn \
    '

alias dairvpn='docker run -d \
    --name airvpn \
    --network airvpn \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -e LOCAL_IPS="192.168.1.0/24" \
    -e EXPOSED_PORTS="8888/tcp 61618/tcp 61618/udp 8388/tcp 8388/udp 1080/tcp" \
    -e VPN_HOSTNAMES="europe.all.vpn.airdns.org" \
    -e CONFIG="airvpn" \
    -p 8888:8888 \
    -p 61618:61618 \
    -p 61618:61618/udp \
    -p 8388:8388 \
    -p 8388:8388/udp \
    -p 1080:1080 \
    vpn \
    '

alias dairvpnstatus='docker exec -ti airvpn curl ifconfig.co/json | jq'

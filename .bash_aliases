alias create-vpn-network='docker network create \
    --subnet=172.30.30.0/24 \
    -o com.docker.network.bridge.enable_ip_masquerade=true \
    -o com.docker.network.bridge.host_binding_ipv4="172.30.30.1" \
    -o com.docker.network.bridge.name="vpnBridge" \
    vpn \
    '

alias dairvpn='docker run -d \
    --name airvpn \
    --network vpn \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -e LOCAL_IPS="192.168.1.0/24" \
    -e EXPOSED_PORTS="8888 61618" \
    -e VPN_HOSTNAMES="europe.all.vpn.airdns.org" \
    -e CONFIG="airvpn" \
    -p 8888:8888 \
    vpn \
    '
alias dsec1vpn='docker run -d \
    --name sec1vpn \
    --network vpn \
    --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -e LOCAL_IPS="192.168.1.0/24" \
    -e EXPOSED_PORTS="" \
    -e VPN_HOSTNAMES="vpn.sec-1.com" \
    -e AUTH="userpass" \
    -e CONFIG="sec-1" \
    vpn \
    '

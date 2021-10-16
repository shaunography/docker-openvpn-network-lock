FROM ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update -y -qq \
 && apt-get install -y \
        curl \
        dnsutils iputils-ping traceroute iproute2 iptables tcpdump ufw \
        openvpn \
        shadowsocks-libev \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY ./openvpn/ /etc/openvpn/
COPY ./ufw_on.sh /opt/
COPY ./entry.sh /opt/

ENTRYPOINT ["bash", "/opt/entry.sh"]

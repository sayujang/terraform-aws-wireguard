#!/bin/bash
#enable trace loggin and fail fast 
set -e
set -x
export DEBIAN_FRONTEND=noninteractive
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
apt update && apt install wireguard -y
SERV_PRIV_KEY=$(wg genkey)
SERV_PUB_KEY=$(echo "$SERV_PRIV_KEY" | wg pubkey)
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
INTERFACE=$(ip route list default | awk '{print $5}')
PUBLIC_IP=$(curl -s checkip.amazonaws.com)
cat << EOF > /etc/wireguard/wg0.conf
[Interface]
#vpn server ip 
Address = 10.8.0.1/24
#ec2 instance listens to this port
ListenPort = 51820
PrivateKey = $SERV_PRIV_KEY

#runs when vpn starts up
PostUp = iptables -t nat -I POSTROUTING -o $INTERFACE -j MASQUERADE

# runs when vpn stops
PreDown = iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUB_KEY
AllowedIPs = 10.8.0.2/32
EOF
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0
cat << EOF > ~/client.conf
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
# vpn private ip for the client
Address = 10.8.0.2/24
#routing through tunnel
DNS = 1.1.1.1

[Peer]
PublicKey = $SERV_PUB_KEY
Endpoint = $PUBLIC_IP:51820
#route both ipv4 and ipv6 to prevent any leakage
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
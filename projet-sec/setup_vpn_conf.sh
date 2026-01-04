#!/bin/bash
# Génération des configs OpenVPN pour le Projet Sécu
# IP du Serveur VPN (R1-eth0) : 10.0.0.1

DIR="vpn_pki"
PWD=$(pwd)/$DIR

# 1. Configuration du SERVEUR (Pour R1)
cat > $DIR/server.conf <<EOL
port 1194
proto udp
dev tun
ca $PWD/ca.crt
cert $PWD/server.crt
key $PWD/server.key
dh $PWD/dh2048.pem
tls-auth $PWD/ta.key 0
server 10.8.0.0 255.255.255.0
push "route 192.168.10.0 255.255.255.0"
keepalive 10 120
cipher AES-256-CBC
user root
group root
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOL

# 2. Configuration du CLIENT (Pour h_ext)
cat > $DIR/client.conf <<EOL
client
dev tun
proto udp
remote 10.0.0.1 1194
resolv-retry infinite
nobind
user root
group root
persist-key
persist-tun
ca $PWD/ca.crt
cert $PWD/client.crt
key $PWD/client.key
remote-cert-tls server
tls-auth $PWD/ta.key 1
cipher AES-256-CBC
verb 3
EOL

echo "✅ Fichiers server.conf et client.conf générés dans $DIR"

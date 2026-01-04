#!/bin/bash

# --- 1. Nettoyage des règles existantes ---
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# --- 2. Politique par DÉFAUT : TOUT BLOQUER (DROP) ---
# C'est le coeur du Zero Trust. Si ce n'est pas explicitement autorisé, c'est interdit.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# --- 3. Règles de base (Infrastructure) ---
# Autoriser le loopback (processus locaux)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# IMPORTANT : Autoriser le trafic "Stateful"
# Si une connexion est déjà validée (ex: retour d'une requête web), on laisse passer la réponse.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# --- 4. Règles Métier (Autorisations Spécifiques) ---

# [ZONE WAN -> DMZ] : Le public peut accéder au Site Web (HTTP/HTTPS)
# 192.168.10.10 est l'IP du serveur web
iptables -A FORWARD -i r1-eth0 -o r1-eth1 -p tcp -d 192.168.10.10 --dport 80 -j ACCEPT
iptables -A FORWARD -i r1-eth0 -o r1-eth1 -p tcp -d 192.168.10.10 --dport 443 -j ACCEPT

# [ZONE LAN -> DMZ] : L'Admin peut administrer le serveur web (SSH + Web)
# 192.168.20.10 est l'IP de l admin
iptables -A FORWARD -i r1-eth2 -o r1-eth1 -s 192.168.20.10 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i r1-eth2 -o r1-eth1 -s 192.168.20.10 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i r1-eth2 -o r1-eth1 -s 192.168.20.10 -p tcp --dport 443 -j ACCEPT

# [ZONE LAN -> WAN] : L'Admin a besoin d'internet (Mises à jour, etc.)
iptables -A FORWARD -i r1-eth2 -o r1-eth0 -s 192.168.20.10 -j ACCEPT

# [DIAGNOSTIC] : Autoriser le PING seulement depuis l'Admin vers partout (pour tester)
iptables -A FORWARD -i r1-eth2 -s 192.168.20.10 -p icmp -j ACCEPT

# --- 5. Journalisation (Logging) ---
# Tout ce qui n'a pas été accepté plus haut sera loggué avant d'être jeté par la politique par défaut.
iptables -A FORWARD -j LOG --log-prefix "FIREWALL_DROP: " --log-level 4

# Autoriser SSH (Port 2222) de l'Admin vers le Serveur Web
iptables -A FORWARD -p tcp --dport 2222 -d 192.168.10.10 -j ACCEPT



echo "--- Autorisation VPN (OpenVPN) ---"
# 1. Autoriser le trafic UDP 1194 entrant sur R1 (Pour établir le tunnel)
iptables -A INPUT -p udp --dport 1194 -j ACCEPT

# 2. Autoriser le trafic à l'intérieur du tunnel (Interface tun+)
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -o tun+ -j ACCEPT
echo "✅ Règles pare-feu Zero Trust appliquées sur R1"

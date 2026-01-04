#!/usr/bin/python

"""
Projet Infrastructure Sécurisée - LSI3
Description: Topologie Mininet pour Debian 13.

"""

from mininet.net import Mininet
from mininet.node import Controller, OVSKernelSwitch, Host
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink
import os

def create_topology():
    # 1. Nettoyage préalable
    os.system("mn -c > /dev/null 2>&1")

    # Initialisation du réseau
    net = Mininet(controller=Controller, link=TCLink, switch=OVSKernelSwitch)

    info( '*** Démarrage du Contrôleur\n' )
    c0 = net.addController('c0')

    info( '*** Création des Zones (Switchs)\n' )
    s_wan = net.addSwitch('s1') # Zone Internet
    s_dmz = net.addSwitch('s2') # Zone Démilitarisée
    s_lan = net.addSwitch('s3') # Zone Interne

    info( '*** Création du Routeur Central\n' )
    r1 = net.addHost('r1', ip='10.0.0.1/24')

    info( '*** Création des Hôtes\n' )
    # --- ZONE WAN ---
    h_ext = net.addHost('h_ext', ip='10.0.0.254/24', defaultRoute='via 10.0.0.1')
    
    # --- ZONE DMZ (CLUSTER WEB) ---
    # Serveur Web 1 (Principal)
    srv_web = net.addHost('web', ip='192.168.10.10/24', defaultRoute='via 192.168.10.1')
    # Serveur Web 2 (Secours / Backup) -> AJOUTÉ ICI
    srv_web2 = net.addHost('web2', ip='192.168.10.11/24', defaultRoute='via 192.168.10.1')
    
    # --- ZONE LAN ---
    h_admin = net.addHost('admin', ip='192.168.20.10/24', defaultRoute='via 192.168.20.1')
    srv_db = net.addHost('db', ip='192.168.20.20/24', defaultRoute='via 192.168.20.1')

    info( '*** Création des Liens Physiques\n' )
    
    # Connexions Routeur -> Switchs
    net.addLink(r1, s_wan, intfName1='r1-eth0')
    net.addLink(r1, s_dmz, intfName1='r1-eth1')
    net.addLink(r1, s_lan, intfName1='r1-eth2')

    # Connexions Hôtes -> Switchs
    net.addLink(h_ext, s_wan)
    net.addLink(srv_web, s_dmz)
    net.addLink(srv_web2, s_dmz) # Lien pour le serveur de secours
    net.addLink(h_admin, s_lan)
    net.addLink(srv_db, s_lan)

    info( '*** Démarrage du réseau\n' )
    net.build()
    c0.start()
    s_wan.start([c0])
    s_dmz.start([c0])
    s_lan.start([c0])

    info( '*** Configuration du Routage\n' )
    
    # Routeur R1
    r1.cmd("sysctl -w net.ipv4.ip_forward=1")
    r1.cmd("ip addr add 10.0.0.1/24 dev r1-eth0")
    r1.cmd("ip link set dev r1-eth0 up")
    r1.cmd("ip addr add 192.168.10.1/24 dev r1-eth1")
    r1.cmd("ip link set dev r1-eth1 up")
    r1.cmd("ip addr add 192.168.20.1/24 dev r1-eth2")
    r1.cmd("ip link set dev r1-eth2 up")

    # Désactivation IPv6
    for host in net.hosts:
        host.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        host.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")

    info( '*** Topologie prête ! Le serveur de secours est "web2" (192.168.10.11)\n' )
    CLI(net)
    
    info( '*** Arrêt du réseau\n' )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    create_topology()


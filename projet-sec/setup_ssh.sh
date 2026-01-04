#!/bin/bash

echo "--- 1. Nettoyage et création des dossiers ---"
rm -rf ssh_admin ssh_web
mkdir -p ssh_admin ssh_web

echo "--- 2. Génération des clés de l'Admin (Client) ---"
# Clé privée et publique pour l'admin
ssh-keygen -t rsa -b 2048 -f ssh_admin/id_rsa -q -N ""
chmod 600 ssh_admin/id_rsa

echo "--- 3. Génération de la clé du Serveur (Host Key) ---"
# Clé d'identité du serveur Web (pour qu'il puisse chiffrer la connexion)
ssh-keygen -t rsa -f ssh_web/ssh_host_rsa_key -q -N ""

echo "--- 4. Installation de la clé publique ---"
# On autorise la clé de l'admin sur le serveur
cat ssh_admin/id_rsa.pub > ssh_web/authorized_keys
chmod 600 ssh_web/authorized_keys

echo "--- 5. Création de la config SSHD sécurisée ---"
# Configuration stricte : Port 2222, Pas de mot de passe, Clé obligatoire
cat > ssh_web/sshd_config <<EOL
Port 2222
HostKey $(pwd)/ssh_web/ssh_host_rsa_key
AuthorizedKeysFile $(pwd)/ssh_web/authorized_keys
PidFile $(pwd)/ssh_web/sshd.pid
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM no
EOL

echo "✅ Configuration terminée ! Prêt pour le test T6."

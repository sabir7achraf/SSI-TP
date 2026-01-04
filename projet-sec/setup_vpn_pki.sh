#!/bin/bash
# Script de génération PKI pour OpenVPN (Projet Secu)

DIR="vpn_pki"
rm -rf $DIR
mkdir -p $DIR
cd $DIR

echo "--- 1. Création de l'Autorité de Certification (CA) ---"
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=FR/ST=Paris/L=Paris/O=ProjetSecu/CN=MiniCA"

echo "--- 2. Création du Certificat Serveur (pour la Gateway) ---"
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/C=FR/ST=Paris/O=ProjetSecu/CN=server"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650

echo "--- 3. Création du Certificat Client (pour h_ext) ---"
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr -subj "/C=FR/ST=Paris/O=ProjetSecu/CN=client"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 3650

echo "--- 4. Paramètres Diffie-Hellman (Rapide pour le test) ---"
# On utilise des paramètres pré-générés ou rapides pour éviter d'attendre 10 minutes
openssl dhparam -out dh2048.pem 2048

echo "--- 5. Clé d'authentification HMAC (Sécurité supplémentaire) ---"
openvpn --genkey secret ta.key

echo "✅ Tous les certificats sont prêts dans le dossier $(pwd)"

#!/bin/bash
# Script de validation globale (T12.1)
# Adapté pour l'architecture Mininet DMZ

TARGET="192.168.10.10"
REPORT="rapport_final.txt"

echo "--- RAPPORT DE VALIDATION FINALE ---" > $REPORT
echo "Date: $(date)" >> $REPORT
echo "Cible: $TARGET" >> $REPORT
echo "-----------------------------------" >> $REPORT

# TEST 1 : Disponibilité du Service Web (DOIT REUSSIR)
echo "[*] Test 1: Accès Web (HTTP Port 80)..."
# On cherche le code HTTP 200 ou du contenu
if curl -s --connect-timeout 2 http://$TARGET ; then
    echo "WEB (HTTP): SUCCÈS (Le site est accessible)" >> $REPORT
    echo "   -> Résultat: OK"
else
    echo "WEB (HTTP): ÉCHEC (Le site est injoignable)" >> $REPORT
    echo "   -> Résultat: FAIL"
fi

# TEST 2 : Efficacité du Pare-feu sur SSH (DOIT ECHOUER)
echo "[*] Test 2: Blocage SSH (Port 22)..."
# nc -z -v -w 2 vérifie si le port est ouvert
if ! nc -z -w 2 $TARGET 22 2>/dev/null; then
    echo "FIREWALL (SSH Block): SUCCÈS (Port 22 bien fermé)" >> $REPORT
    echo "   -> Résultat: OK"
else
    echo "FIREWALL (SSH Block): ÉCHEC (Port 22 est OUVERT !)" >> $REPORT
    echo "   -> Résultat: FAIL"
fi

# TEST 3 : Protection Base de Données (DOIT ECHOUER depuis WAN)
echo "[*] Test 3: Accès Base de Données (192.168.20.20)..."
if ! ping -c 1 -W 1 192.168.20.20 > /dev/null 2>&1; then
    echo "ISOLATION DB: SUCCÈS (LAN inaccessible)" >> $REPORT
    echo "   -> Résultat: OK"
else
    echo "ISOLATION DB: ÉCHEC (LAN accessible !)" >> $REPORT
    echo "   -> Résultat: FAIL"
fi

echo "-----------------------------------" >> $REPORT
echo "RAPPORT GÉNÉRÉ : $REPORT"


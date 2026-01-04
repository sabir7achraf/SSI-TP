import socket
import json
import time
import os

# Configuration des cibles
TARGET_WEB = "192.168.10.10"
TARGET_DB = "192.168.20.20"
REPORT_FILE = "rapport_final.json"

results = {
    "timestamp": time.ctime(),
    "tests": []
}

def log_test(name, status, details):
    print(f"[{'OK' if status else 'FAIL'}] {name}")
    results["tests"].append({
        "test_name": name,
        "success": status,
        "details": details
    })

def check_port(ip, port, expect_open=True):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2) # Timeout court pour aller vite
    try:
        result = s.connect_ex((ip, port))
        is_open = (result == 0)
        
        if expect_open:
            status = is_open
            msg = f"Port {port} ouvert" if is_open else f"Port {port} fermé (Attendu: Ouvert)"
        else:
            status = not is_open
            msg = f"Port {port} filtré/fermé" if not is_open else f"ALERTE: Port {port} ouvert (Attendu: Fermé)"
            
        s.close()
        return status, msg
    except Exception as e:
        return False, str(e)

print("--- DEMARRAGE DE L'AUDIT AUTOMATISE (T12) ---")

# TEST 1 : Accessibilité Web (Doit être OK)
status, msg = check_port(TARGET_WEB, 80, expect_open=True)
log_test("Accès Service Web (HTTP)", status, msg)

# TEST 2 : Sécurité SSH (Doit être Bloqué depuis WAN)
status, msg = check_port(TARGET_WEB, 22, expect_open=False)
log_test("Blocage SSH depuis WAN", status, msg)

# TEST 3 : Sécurité Base de Données (Doit être Bloqué)
status, msg = check_port(TARGET_DB, 3306, expect_open=False)
log_test("Invisibilité Base de Données", status, msg)

# TEST 4 : Ping LAN (Optionnel, via commande système)
response = os.system(f"ping -c 1 -W 1 {TARGET_DB} > /dev/null 2>&1")
log_test("Isolation ICMP (Ping LAN)", response != 0, "Ping bloqué comme prévu" if response != 0 else "Ping réussi (Fail)")

# Génération du rapport
with open(REPORT_FILE, "w") as f:
    json.dump(results, f, indent=4)

print(f"\n--- AUDIT TERMINÉ. Rapport généré : {REPORT_FILE} ---")

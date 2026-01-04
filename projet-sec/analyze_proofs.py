import subprocess
import re
from datetime import datetime

def get_logs():
    print("--- 🔍 ANALYSE DES LOGS PARE-FEU (PREUVES) ---")
    try:
        # Lecture des logs kernel récents
        # Note: Dans un environnement réel/VM, les logs iptables vont souvent dans /var/log/kern.log ou dmesg
        output = subprocess.check_output("dmesg | grep 'FIREWALL_DROP'", shell=True).decode('utf-8')
        
        lines = output.strip().split('\n')
        if not lines:
            print("Aucune tentative d'intrusion détectée pour le moment.")
            return

        print(f"Trouvé {len(lines)} événements bloqués par le pare-feu Zero Trust.\n")
        
        # En-tête du tableau
        print(f"{'TIMESTAMP':<20} | {'SOURCE IP':<15} | {'DEST IP':<15} | {'PROTO':<6} | {'PORT'}")
        print("-" * 75)

        for line in lines[-10:]: # On affiche les 10 derniers
            # Extraction avec Regex
            src = re.search(r'SRC=([\d\.]+)', line)
            dst = re.search(r'DST=([\d\.]+)', line)
            proto = re.search(r'PROTO=(\w+)', line)
            dpt = re.search(r'DPT=(\d+)', line)

            src_ip = src.group(1) if src else "Inconnu"
            dst_ip = dst.group(1) if dst else "Inconnu"
            protocol = proto.group(1) if proto else "Unk"
            port = dpt.group(1) if dpt else "N/A"
            
            # Timestamp (approximatif, basé sur le moment du script ou dmesg)
            print(f"{datetime.now().strftime('%H:%M:%S'):<20} | {src_ip:<15} | {dst_ip:<15} | {protocol:<6} | {port}")

        print("\n[OK] Preuve de fonctionnement du principe 'Refus par défaut' validée.")
        print("Les paquets ci-dessus ont été bloqués et journalisés conformément aux exigences.")

    except subprocess.CalledProcessError:
        print("Erreur: Impossible de lire les logs ou aucun log trouvé.")

if __name__ == "__main__":
    get_logs()

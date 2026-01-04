import http.server, ssl, socketserver

# Configuration
PORT = 443
CERT_FILE = 'server.pem'

# Gestionnaire de requêtes simple
class SecureHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # On renvoie une page HTML simple pour prouver que ça marche
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"<html><body><h1>SUCCES : Acces Securise HTTPS Valide !</h1></body></html>")

# Création du serveur
server_address = ('0.0.0.0', PORT)
httpd = http.server.HTTPServer(server_address, SecureHandler)

# Activation du SSL (HTTPS)
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(certfile=CERT_FILE)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)

print(f"Serveur HTTPS securise en ecoute sur le port {PORT}...")
httpd.serve_forever()

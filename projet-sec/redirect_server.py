import http.server
import socketserver

# On écoute sur le port 80 (HTTP standard)
PORT = 80

class RedirectHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # On renvoie une erreur 301 (Moved Permanently)
        self.send_response(301)
        # On définit la nouvelle adresse (Même IP, mais en HTTPS)
        new_url = 'https://192.168.10.10' + self.path
        self.send_header('Location', new_url)
        self.end_headers()

print(f"Serveur de redirection HTTP (Port {PORT}) actif...")
with socketserver.TCPServer(("", PORT), RedirectHandler) as httpd:
    httpd.serve_forever()

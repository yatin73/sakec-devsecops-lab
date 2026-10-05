#!/usr/bin/env python3
"""Minimal sample app used throughout the SAKEC DevSecOps lab.

Intentionally dependency-light (Python standard library only) so Day 3
students can run it directly on EC2 without installing extra packages,
and so Day 4 can Dockerize it trivially.
"""
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("PORT", 5000))


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        html = f"""
        <html>
          <head><title>SAKEC DevSecOps Lab</title></head>
          <body style="font-family: sans-serif; text-align:center; margin-top: 10%;">
            <h1>Hello from SAKEC DevSecOps Lab!</h1>
            <p>This app is running on port {PORT}.</p>
            <p>Deployed via: EC2 &rarr; Docker &rarr; Jenkins &rarr; Terraform &rarr; Cloudflare</p>
          </body>
        </html>
        """
        self.wfile.write(html.encode("utf-8"))

    def log_message(self, format, *args):
        # Keep container/EC2 logs concise during lab demos
        print(f"{self.address_string()} - {format % args}")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Serving on http://0.0.0.0:{PORT}")
    server.serve_forever()

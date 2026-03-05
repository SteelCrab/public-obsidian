#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx python3-pip python3-venv

# FastAPI 앱 설정
mkdir -p /app
python3 -m venv /app/venv
/app/venv/bin/pip install fastapi uvicorn

cat > /app/main.py << 'PYEOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"service": "pista-3tier", "status": "ok"}

@app.get("/health")
def health():
    return {"health": "ok"}
PYEOF

# FastAPI systemd 서비스
cat > /etc/systemd/system/fastapi.service << 'EOF'
[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/app
ExecStart=/app/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Nginx → FastAPI 프록시 설정
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;

    location /health {
        return 200 'ok';
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi

systemctl enable nginx
systemctl restart nginx

echo "app init done" >> /var/log/app-init.log

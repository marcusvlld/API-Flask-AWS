#!/bin/bash

# Atualiza pacotes
yum update -y || apt-get update -y

# Detecta distro para usar o gerenciador correto
if [ -f /etc/os-release ] && grep -q "Amazon Linux" /etc/os-release; then
    # Amazon Linux 2
    yum install -y python3 git
    pip3 install --upgrade pip
else
    # Assume Ubuntu
    apt-get install -y python3 python3-venv python3-pip git
fi

# Cria diretório da aplicação
APP_DIR=/opt/userinfoapi
mkdir -p ${APP_DIR}
cd ${APP_DIR}

# Clona repo (ou atualiza se já existir)
if [ -n "${github_repo}" ]; then
    if [ -d "${APP_DIR}/.git" ]; then
        git -C ${APP_DIR} pull || true
    else
        git clone "${github_repo}" ${APP_DIR} || true
    fi
fi

# Cria venv e instala dependências
python3 -m venv venv
source venv/bin/activate

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Cria systemd service para rodar a app com gunicorn (fallback para flask run)
SERVICE_FILE=/etc/systemd/system/userinfoapi.service
cat > ${SERVICE_FILE} <<'EOF'
[Unit]
Description=UserInfoAPI
After=network.target

[Service]
User=root
WorkingDirectory=/opt/userinfoapi
Environment="PATH=/opt/userinfoapi/venv/bin"
ExecStart=/opt/userinfoapi/venv/bin/gunicorn --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Se gunicorn não estiver instalado, instala
source venv/bin/activate
pip install gunicorn || true

# Ativa e inicia o serviço
systemctl daemon-reload
systemctl enable userinfoapi
systemctl start userinfoapi

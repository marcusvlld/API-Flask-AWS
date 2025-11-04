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

# Garante que gunicorn esteja instalado
pip install gunicorn || true

# Cria systemd service para rodar a app com gunicorn
SERVICE_FILE=/etc/systemd/system/userinfoapi.service
cat > ${SERVICE_FILE} <<EOF
[Unit]
Description=UserInfoAPI
After=network.target

[Service]
User=ec2-user
WorkingDirectory=${APP_DIR}
Environment="PATH=${APP_DIR}/venv/bin"
ExecStart=${APP_DIR}/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF



# Ativa e inicia o serviço
systemctl daemon-reload
systemctl enable userinfoapi
systemctl start userinfoapi

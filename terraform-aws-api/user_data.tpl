#!/bin/bash

# Script de inicialização automática para EC2 com API Flask
# Compatível com Ubuntu
# Executa na criação da instância via Terraform

# ============================================
# 1. Atualizar repositórios do sistema
# ============================================
echo "Atualizando repositórios do sistema..."
apt-get update -y

# ============================================
# 2. Instalar Python 3, pip e git
# ============================================
echo "Instalando Python 3, pip e git..."
apt-get install -y python3 python3-pip git

# Criar link simbólico para facilitar uso do python
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# ============================================
# 3. Criar diretório para a aplicação
# ============================================
echo "Criando diretório de trabalho..."
mkdir -p /opt/apps
cd /opt/apps

# ============================================
# 4. Clonar repositório do projeto
# ============================================
echo "Clonando repositório user-info-api..."
# Substitua ${repo_url} pela variável do Terraform ou cole o URL direto
git clone ${repo_url} user-info-api

# Verificar se o clone foi bem-sucedido
if [ ! -d "user-info-api" ]; then
    echo "Erro: Falha ao clonar o repositório"
    exit 1
fi

# ============================================
# 5. Entrar na pasta do projeto
# ============================================
cd user-info-api

# ============================================
# 6. Instalar dependências do projeto
# ============================================
echo "Instalando dependências Python do requirements.txt..."
pip3 install -r requirements.txt

# ============================================
# 7. Configurar variáveis de ambiente (se necessário)
# ============================================
# Descomente e ajuste se sua API precisar de variáveis de ambiente
# export FLASK_APP=app.py
# export FLASK_ENV=production

# ============================================
# 8. Iniciar a API Flask em background
# ============================================
echo "Iniciando API Flask na porta 5000..."

# Usando nohup para manter o processo rodando após logout
# Redirecionando stdout e stderr para arquivo de log
# O '&' no final executa em background
nohup python3 app.py > /var/log/flask-api.log 2>&1 &

# Salvar o PID do processo para gerenciamento futuro
echo $! > /var/run/flask-api.pid

# ============================================
# 9. Verificar se a API está rodando
# ============================================
sleep 5
if ps -p $(cat /var/run/flask-api.pid) > /dev/null; then
    echo "API Flask iniciada com sucesso! PID: $(cat /var/run/flask-api.pid)"
else
    echo "Erro: Falha ao iniciar a API Flask"
    exit 1
fi

# ============================================
# 10. Configurar restart automático
# ============================================
# Criar script de inicialização systemd (mais robusto que nohup)
cat > /etc/systemd/system/flask-api.service <<EOF
[Unit]
Description=Flask API User Info
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/apps/user-info-api
ExecStart=/usr/bin/python3 /opt/apps/user-info-api/app.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/flask-api.log
StandardError=append:/var/log/flask-api.log

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar o serviço systemd
systemctl daemon-reload
systemctl enable flask-api.service
systemctl restart flask-api.service



echo "Configuração concluída! API Flask disponível na porta 5000"
echo "Logs disponíveis em: /var/log/flask-api.log"
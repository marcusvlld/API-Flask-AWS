#!/bin/bash

# Script de inicialização para EC2 - API Flask
# Compatível com Amazon Linux 2 e Ubuntu


# ============================================
# Configuração de logs para debug
# ============================================
LOGFILE="/var/log/user-data-execution.log"
exec > >(tee -a $LOGFILE) 2>&1
echo "=== Iniciando user_data em $(date) ==="

# ============================================
# Variáveis de configuração
# ============================================
APP_DIR="/opt/api-flask-aws"
API_DIR="$APP_DIR/user_info_api"
GITHUB_REPO="${github_repo}"

APP_USER="flask"
APP_GROUP="flask"

# ============================================
# 1. Detectar distribuição e instalar pacotes
# ============================================
echo "Detectando distribuição..."
if [ -f /etc/os-release ] && grep -q "Amazon Linux" /etc/os-release; then
    echo "Distribuição: Amazon Linux"
    DISTRO="amazon"
    USER="ec2-user"
    
    # Atualizar pacotes
    yum update -y

    echo "Instalando Git..."
    yum install -y git
    
    # Instalar Python 3.10
    amazon-linux-extras enable python3.10
    yum install -y python3.10 python3.10-devel

    # Tornar python3.10 padrão
    alternatives --set python /usr/bin/python3.10

    # Verificar
    python --version
    
else
    echo "Distribuição: Ubuntu/Debian"
    DISTRO="ubuntu"
    USER="ubuntu"
    
    # Atualizar pacotes 
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    
    # Instalar Python 3, pip, venv e git
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        build-essential \
        python3-dev
fi

echo "Pacotes instalados com sucesso"

# ==========================================================
# 2. Criar usuário e grupo da aplicação
# ==========================================================
echo "Criando usuário e grupo da aplicação..."

groupadd $APP_GROUP || true
useradd -r -g $APP_GROUP -s /sbin/nologin $APP_USER || true

usermod -aG $APP_GROUP ec2-user

# ============================================
# 3. Criar diretório e clonar repositório
# ============================================
echo "Criando diretório da aplicação..."
mkdir -p $APP_DIR

echo "Clonando repositório: $GITHUB_REPO"
if [ -z "$GITHUB_REPO" ]; then
    echo "ERRO: Variável github_repo não definida"
    exit 1
fi

# Remove diretório anterior se existir
rm -rf $APP_DIR

# Clona o repositório completo (API-Flask-AWS)
git clone --branch release-2.0 --single-branch $GITHUB_REPO $APP_DIR

if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao clonar repositório"
    exit 1
fi

echo "Repositório clonado com sucesso"

# ============================================
# 4. Verificar estrutura do repositório
# ============================================
echo "Verificando estrutura do projeto..."
if [ ! -d "$API_DIR" ]; then
    echo "ERRO: Diretório user_info_api não encontrado em $APP_DIR"
    echo "Conteúdo de $APP_DIR:"
    ls -la $APP_DIR
    exit 1
fi

echo "Estrutura do projeto:"
ls -la $APP_DIR
echo ""
echo "Conteúdo da pasta user_info_api:"
ls -la $API_DIR

# ============================================
# 5. Verificar arquivos essenciais
# ============================================
if [ ! -f "$API_DIR/app.py" ]; then
    echo "ERRO: app.py não encontrado em $API_DIR"
    exit 1
fi

if [ ! -f "$API_DIR/requirements.txt" ]; then
    echo "AVISO: requirements.txt não encontrado em $API_DIR"
fi

echo "Arquivos essenciais encontrados!"

# ============================================
# 6. Criar ambiente virtual
# ============================================
echo "Criando ambiente virtual em $APP_DIR/venv..."
cd $API_DIR
python3 -m venv $APP_DIR/venv

if [ ! -f "$APP_DIR/venv/bin/activate" ]; then
    echo "ERRO: Falha ao criar ambiente virtual"
    exit 1
fi

echo "Ativando ambiente virtual..."
source $APP_DIR/venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# ============================================
# 7. Instalar dependências
# ============================================
echo "Atualizando pip..."
pip install --upgrade pip

echo "Instalando dependências do requirements.txt..."
if [ -f "$API_DIR/requirements.txt" ]; then
    pip install -r $API_DIR/requirements.txt
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao instalar dependências"
        exit 1
    fi
fi

# Garantir que Flask e Gunicorn estejam instalados
echo "Instalando Flask e Gunicorn..."
pip install gunicorn flask==2.2.5 flask-cors

echo "Pacotes Python instalados:"
pip list | grep -E "Flask|gunicorn"

# ============================================
# 8. Ajustar permissões
# ============================================
echo "Ajustando permissões..."
chown -R root:$APP_GROUP $APP_DIR
chmod -R 775 $APP_DIR

# ============================================
# 9. Criar serviço systemd
# ============================================
echo "Criando serviço systemd..."
SERVICE_FILE="/etc/systemd/system/flask-api.service"

cat > $SERVICE_FILE <<EOF
[Unit]
Description=Flask User Info API
After=network.target

[Service]
Type=simple
User=$APP_USER
Group=$APP_GROUP
WorkingDirectory=$API_DIR
Environment="PATH=$APP_DIR/venv/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="FLASK_APP=app.py"

# Usando Gunicorn 
ExecStart=$APP_DIR/venv/bin/gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 2 \
    --timeout 120 \
    --access-logfile /opt/api-flask-aws/user_info_api/logs/access.log \
    --error-logfile /opt/api-flask-aws/user_info_api/logs/error.log \
    app:app

Restart=always
RestartSec=10


[Install]
WantedBy=multi-user.target
EOF

echo "Conteúdo do serviço criado:"
cat $SERVICE_FILE

# ============================================
# 10. Ativar e iniciar o serviço
# ============================================
echo "Recarregando systemd daemon..."
systemctl daemon-reload

echo "Habilitando serviço para iniciar no boot..."
systemctl enable flask-api

echo "Iniciando serviço..."
systemctl start flask-api

# ==========================================================
# 11. Permitir restart via GitHub Actions
# ==========================================================
echo "Configurando sudo para deploy..."
echo "ec2-user ALL=(ALL) NOPASSWD: /bin/systemctl restart flask-api" > /etc/sudoers.d/flask-api
chmod 440 /etc/sudoers.d/flask-api

# ============================================
# 12. Aguardar e verificar status
# ============================================
echo "Aguardando 10 segundos para a aplicação iniciar..."
sleep 10

echo "=== STATUS DO SERVIÇO ==="
systemctl status flask-api --no-pager

echo ""
echo "=== VERIFICANDO PORTA 5000 ==="
if command -v netstat &> /dev/null; then
    netstat -tuln | grep 5000
elif command -v ss &> /dev/null; then
    ss -tuln | grep 5000
else
    echo "netstat/ss não disponível"
fi

echo ""
echo "=== ÚLTIMAS LINHAS DO LOG DE ERRO ==="
if [ -f /opt/api-flask-aws/user_info_api/logs/error.log ]; then
    tail -20 /opt/api-flask-aws/user_info_api/logs/error.log
else
    echo "Arquivo de log ainda não criado"
fi

# ============================================
# 13. Teste básico da API
# ============================================
echo ""
echo "=== TESTANDO API LOCALMENTE ==="
sleep 5

# Tentar fazer uma requisição para a API
if command -v curl &> /dev/null; then
    echo "Fazendo requisição para http://localhost:5000/"
    curl -v http://localhost:5000/ 2>&1 || echo "AVISO: Falha ao conectar na API"
else
    echo "curl não disponível para teste"
fi

# ============================================
# 14. Informações finais
# ============================================
echo ""
echo "=== INFORMAÇÕES FINAIS ==="
echo "Diretório da aplicação: $APP_DIR"
echo "Diretório da API: $API_DIR"
echo "Ambiente virtual: $APP_DIR/venv"
echo ""
echo "=== COMANDOS ÚTEIS PARA DEBUG ==="
echo "Ver logs do user_data: sudo cat /var/log/user-data-execution.log"
echo "Ver status do serviço: sudo systemctl status flask-api"
echo "Ver logs em tempo real: sudo journalctl -u flask-api -f"
echo "Ver logs de erro: sudo tail -f /var/log/flask-error.log"
echo "Reiniciar serviço: sudo systemctl restart flask-api"
echo "Testar API: curl http://localhost:5000/"
echo ""
echo "=== user_data finalizado em $(date) ==="

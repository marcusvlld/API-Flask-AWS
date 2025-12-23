#!/bin/bash
set -e

LOGFILE="/var/log/user-data-docker.log"
exec > >(tee -a $LOGFILE) 2>&1

echo "=== Iniciando user_data Docker em $(date) ==="

# ===============================
# 1. Atualizar sistema
# ===============================
yum update -y

# ===============================
# 2. Instalar Docker
# ===============================
echo "Instalando Docker..."
yum install -y docker

# ===============================
# 3. Iniciar e habilitar Docker
# ===============================
systemctl start docker
systemctl enable docker

# Permitir ec2-user usar docker sem sudo
usermod -aG docker ec2-user

echo "=== user_data Docker finalizado em $(date) ==="

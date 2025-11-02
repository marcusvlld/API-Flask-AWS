"""
UserInfoAPI - API REST para gerenciamento de informações de usuários
Desenvolvido para portfólio na AWS EC2
"""

from flask import Flask, jsonify, request
from flask_cors import CORS

# Inicialização da aplicação Flask
app = Flask(__name__)
CORS(app)  # Habilita CORS para permitir requisições de outras origens

# Base de dados fictícia de usuários (em produção, usar um banco de dados real)
USERS_DB = {
    1: {
        "id": 1,
        "nome": "Ana Silva",
        "email": "ana.silva@email.com",
        "cidade": "São Paulo"
    },
    2: {
        "id": 2,
        "nome": "Carlos Santos",
        "email": "carlos.santos@email.com",
        "cidade": "Rio de Janeiro"
    },
    3: {
        "id": 3,
        "nome": "Maria Oliveira",
        "email": "maria.oliveira@email.com",
        "cidade": "Belo Horizonte"
    },
    4: {
        "id": 4,
        "nome": "João Pereira",
        "email": "joao.pereira@email.com",
        "cidade": "Brasília"
    },
    5: {
        "id": 5,
        "nome": "Paula Costa",
        "email": "paula.costa@email.com",
        "cidade": "Porto Alegre"
    }
}


# Rota principal - Health Check
@app.route('/', methods=['GET'])
def home():
    """
    Endpoint de health check para verificar se a API está ativa
    """
    return jsonify({
        "status": "success",
        "message": "API UserInfo ativa e rodando",
        "version": "1.0.0",
        "endpoints": {
            "GET /": "Health check",
            "GET /users": "Lista todos os usuários",
            "GET /users/<id>": "Retorna usuário específico por ID"
        }
    }), 200


# Rota para listar todos os usuários
@app.route('/users', methods=['GET'])
def get_users():
    """
    Retorna a lista completa de usuários cadastrados
    """
    try:
        # Converte o dicionário em uma lista de usuários
        users_list = list(USERS_DB.values())
        
        return jsonify({
            "status": "success",
            "total": len(users_list),
            "data": users_list
        }), 200
    
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": "Erro ao buscar usuários",
            "error": str(e)
        }), 500


# Rota para buscar usuário específico por ID
@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """
    Retorna os dados de um usuário específico pelo ID
    
    Args:
        user_id (int): ID do usuário a ser buscado
    """
    try:
        # Verifica se o usuário existe no banco de dados
        user = USERS_DB.get(user_id)
        
        if user:
            return jsonify({
                "status": "success",
                "data": user
            }), 200
        else:
            return jsonify({
                "status": "error",
                "message": f"Usuário com ID {user_id} não encontrado",
                "available_ids": list(USERS_DB.keys())
            }), 404
    
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": "Erro ao buscar usuário",
            "error": str(e)
        }), 500


# Tratamento de erro 404 - Rota não encontrada
@app.errorhandler(404)
def not_found(error):
    """
    Manipulador personalizado para erros 404
    """
    return jsonify({
        "status": "error",
        "message": "Endpoint não encontrado",
        "error": "404 Not Found"
    }), 404


# Tratamento de erro 500 - Erro interno do servidor
@app.errorhandler(500)
def internal_error(error):
    """
    Manipulador personalizado para erros 500
    """
    return jsonify({
        "status": "error",
        "message": "Erro interno do servidor",
        "error": "500 Internal Server Error"
    }), 500


# Ponto de entrada da aplicação
if __name__ == '__main__':
    # Configurações para execução em produção na AWS EC2
    # host='0.0.0.0' permite acesso externo
    # debug=False em produção (mude para True apenas em desenvolvimento)
    app.run(host='0.0.0.0', port=5000, debug=False)


"""
=============================================================================
INSTRUÇÕES DE INSTALAÇÃO E EXECUÇÃO
=============================================================================

1. INSTALAÇÃO DAS DEPENDÊNCIAS:
   
   # Atualizar sistema (Ubuntu/Debian)
   sudo apt update && sudo apt upgrade -y
   
   # Instalar Python e pip
   sudo apt install python3 python3-pip -y
   
   # Instalar dependências do projeto
   pip3 install flask flask-cors

2. EXECUÇÃO LOCAL (Desenvolvimento):
   
   python3 app.py
   
   Ou com permissões adequadas:
   chmod +x app.py
   ./app.py

3. TESTANDO A API:
   
   # Health check
   curl http://localhost:5000/
   
   # Listar todos os usuários
   curl http://localhost:5000/users
   
   # Buscar usuário específico
   curl http://localhost:5000/users/1

4. EXECUÇÃO EM PRODUÇÃO (AWS EC2):
   
   # Opção 1: Usando nohup (simples)
   nohup python3 app.py > api.log 2>&1 &
   
   # Opção 2: Usando systemd (recomendado)
   # Criar arquivo /etc/systemd/system/userinfo-api.service:
   
   [Unit]
   Description=UserInfo API Service
   After=network.target
   
   [Service]
   Type=simple
   User=ubuntu
   WorkingDirectory=/home/ubuntu/userinfo-api
   ExecStart=/usr/bin/python3 /home/ubuntu/userinfo-api/app.py
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   
   # Comandos systemd:
   sudo systemctl daemon-reload
   sudo systemctl start userinfo-api
   sudo systemctl enable userinfo-api
   sudo systemctl status userinfo-api

5. CONFIGURAÇÃO DO SECURITY GROUP NA AWS:
   
   - Liberar porta 5000 (Custom TCP) para seu IP ou 0.0.0.0/0
   - Liberar porta 22 (SSH) para administração
   - Recomenda-se usar HTTPS (porta 443) com nginx como proxy reverso

6. MELHORIAS PARA PRODUÇÃO:
   
   - Usar Gunicorn como WSGI server:
     pip3 install gunicorn
     gunicorn -w 4 -b 0.0.0.0:5000 app:app
   
   - Configurar nginx como proxy reverso
   - Adicionar SSL/TLS com Let's Encrypt
   - Implementar autenticação e rate limiting
   - Conectar a um banco de dados real (PostgreSQL, MySQL)
   - Adicionar logging estruturado
   - Implementar monitoramento (CloudWatch, Prometheus)

=============================================================================
ENDPOINTS DISPONÍVEIS:
=============================================================================

GET /                  → Health check e informações da API
GET /users             → Lista todos os usuários
GET /users/<id>        → Retorna usuário específico por ID

=============================================================================
"""
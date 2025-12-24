# API Flask AWS — Release 2.0
Esta branch representa a **versão 2.0** da API Flask, com foco em **automação de deploy, containerização e boas práticas de CI/CD**.

## Principais melhorias da Release 2.0
Em comparação com a versão anterior, esta release introduz:

- Pipeline de CI com **build e testes automatizados**
- Containerização completa da aplicação com **Docker**
- Pipeline de CD com **build, push e deploy automático**
- Deploy em **EC2 via Docker**, sem dependência de systemd
- Uso de **GitHub Secrets** para segurança
- `user_data` simplificado (infra prepara ambiente Docker apenas)

## Arquitetura da aplicação
A arquitetura atual segue o fluxo abaixo:

1. Push ou PR para a branch `release-2.0`
2. GitHub Actions executa:
   - Build do projeto
   - Testes com pytest
3. Build da imagem Docker
4. Push da imagem para o Docker Hub
5. Deploy automático na EC2:
   - Pull da imagem
   - Stop do container antigo
   - Start do novo container
  
<img width="838" height="160" alt="Diagrama sem nome drawio (4)" src="https://github.com/user-attachments/assets/81466ecb-698a-40d6-9ffc-21636956b7b9" />

## CI/CD com GitHub Actions
Este projeto utiliza um workflow principal com três jobs:

### 1. Job de build + test

<img width="464" height="601" alt="Captura de tela 2025-12-24 111814" src="https://github.com/user-attachments/assets/acac4372-359a-46a3-b919-bb6ed57cf3ad" />

Responsável por:
- Checkout do código
- Setup do Python
- Instalação das dependências
- Execução dos testes com pytest

### 2. Job buld + push de imagem Docker

<img width="505" height="403" alt="Captura de tela 2025-12-24 111833" src="https://github.com/user-attachments/assets/a60d5438-272a-4200-90f5-6a7c9a456c2e" />

Responsável por:
- Fazer login no Docker Hub
- Build da imagem Docker
- Push para o Docker Hub

### 3. Job de deploy na EC2

<img width="959" height="449" alt="Captura de tela 2025-12-24 111846" src="https://github.com/user-attachments/assets/2a69e445-3a87-4402-a0cb-9992e67a3677" />

Responsável por:
- Configurar a chave SSH
- Testar a conexão via SSH com a EC2
- Deploy automático na EC2 via SSH

## Docker
A aplicação é empacotada em um container Docker utilizando:

- Python 3.11
- Gunicorn como servidor WSGI
- Porta 5000 exposta no container
- Porta 80 exposta no host

<img width="457" height="353" alt="Captura de tela 2025-12-24 111900" src="https://github.com/user-attachments/assets/a04f8a48-3467-4ee7-91f0-af44b496f491" />

## Infraestrutura
A infraestrutura é provisionada com **Terraform**, incluindo:

- EC2
- Security Group (SSH + HTTP)
- Key Pair
- user_data para instalação do Docker

## Acesso à API
Após o deploy, a API fica disponível em:

http://54.196.153.39/

## Considerações finais
Com as melhorias implementadas neste projeto, foi possível aprofundar o entendimento sobre automação de infraestrutura com Terraform, criação de pipelines CI/CD utilizando GitHub Actions e deploy de aplicações com Docker em ambientes cloud. 

O projeto também reforçou a importância de padronização, versionamento e automação no ciclo de desenvolvimento de software.

## Próximos passos

- Implementar monitoramento com CloudWatch
- Adicionar load balancer
- Configurar banco de dados RDS

## Tecnologias utilizadas

- Terraform  
- AWS EC2  
- Python / Flask  
- Docker  
- GitHub Actions  
- Git / GitHub  
- Postman

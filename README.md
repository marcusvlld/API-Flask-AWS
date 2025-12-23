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
  
*INSERIR DIAGRAMA AQUI*

## CI/CD com GitHub Actions
Este projeto utiliza um workflow principal com três jobs:

### 1. Job de build + test

*INSERIR IMAGEM DO JOB BUILD*

Responsável por:
- Checkout do código
- Setup do Python
- Instalação das dependências
- Execução dos testes com pytest

### 2. Job buld + push de imagem Docker

*INSERIR IMAGEM DO JOB DOCKER*

Responsável por:
- Fazer login no Docker Hub
- Build da imagem Docker
- Push para o Docker Hub

### 3. Job de deploy na EC2

*INSERIR IMAGEM DO JOB DEPLOY*

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

*INSERIR IMAGEM DO DOCKERFILE*

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

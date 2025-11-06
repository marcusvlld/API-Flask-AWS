# Automação de Infraestrutura AWS com Terraform e API Flask

## 1. Visão geral do projeto

Este projeto demonstra o uso de **Infraestrutura como Código (IaC)** com **Terraform** para provisionar automaticamente uma instância **EC2 na AWS**, configurada para **executar uma API Flask** desenvolvida em **Python**.

O objetivo é mostrar como é possível **criar, configurar e iniciar uma aplicação completa em poucos comandos**, unindo **infraestrutura e código** de forma automatizada.

### Fluxo do projeto

<img width="641" height="150" alt="Diagrama sem nome drawio (3)" src="https://github.com/user-attachments/assets/dfee6d48-bf21-4f51-9d68-5ab50d4d4551" />

### Conceitos principais abordados:

- Provisionamento automatizado com terraform
- Execução de scripts de inicialização
- Gerenciamento de infraestrutura na AWS

## 2. Estrutura do Projeto

<img width="170" height="288" alt="Captura de tela 2025-11-05 164230" src="https://github.com/user-attachments/assets/1d4d80a7-30af-422f-bd84-05dcedeff894" />

A estrutura foi organizada para **separar a aplicação e a infraestrutura**:
- user-info-api/: Contém o código da aplicação Flask.
- terraform-aws-api/: Contém os arquivos responsáveis pela criação e configuração da infraestrutura AWS.

Essa separação torna o projeto **mais modular e reutilizável**, permitindo evoluir a API sem alterar o código da infraestrutura (e vice-versa).

## 3. Código da API (Flask)

A API foi desenvolvida com **Flask** e contém rotas simples para retorno de informações fictícias de usuários, servindo como exemplo de deploy rápido e leve em EC2.

### Exemplo de rota:

<img width="825" height="787" alt="Captura de tela 2025-11-04 215420" src="https://github.com/user-attachments/assets/28217b86-0cdb-4dfd-bbb8-49357f32833b" />

## 4. Arquivos Terraform

O projeto contém três arquivos terraform, cada um deles com funções específicas na infraestrutura

### Arquivo variables.tf

<img width="718" height="485" alt="image" src="https://github.com/user-attachments/assets/96674797-0342-4fca-9315-170af149ab99" />

Assim como em seu nome, esse arquivo define variáveis importantes que serão utilizadas para a criação da infraestrutura AWS

### Arquivo main.tf

<img width="705" height="341" alt="Captura de tela 2025-11-04 215513" src="https://github.com/user-attachments/assets/8193452c-3c0d-4a10-9006-706dece171ed" />

Esse é o arquivo principal do Terraform responsável por configurar o provedor AWS e criar a instância EC2 que hospedará a API Flask.

### Arquivo user_data.tpl

<img width="647" height="912" alt="Captura de tela 2025-11-04 215637" src="https://github.com/user-attachments/assets/64e80420-0371-4710-befa-9176d3f48d38" />

Esse arquivo contém o script de inicialização executado pela EC2, responsável por instalar dependências e iniciar automaticamente a API Flask.

### Arquivo outputs.tf

<img width="756" height="340" alt="image" src="https://github.com/user-attachments/assets/2f1dccb7-57af-47f3-95af-ca953e60ef3c" />

Esse arquivo mostra informações úteis após o provisionamento, como o IP público da instância EC2, o comando SSH para conexão remota e a URL da API para testes.

O Terraform é responsável por criar toda a infraestrutura automaticamente, incluindo:
- Instância EC2
- Security Group (liberando a porta 5000)
- Execução automática do user_data que instala dependências e inicia a API

## 5. Pré requisitos para execução do projeto

### Instalação do terraform:

- Para iniciar a instalação do terraform no Linux é necessário primeiramente atualizar os pacotes com o comando:

<img width="386" height="37" alt="image" src="https://github.com/user-attachments/assets/10c82b7d-c993-4fef-bbb7-d23218d3966d" />

- Após atualizado, pode seguir com a instalação utilizando:

<img width="365" height="34" alt="image" src="https://github.com/user-attachments/assets/ebe19503-3b75-4d3b-9cf8-4e46931831fb" />

### Criação da chave SSH local:
- Para gerar a chave SSH local é preciso apenas rodar esse comando no terminal linux:

<img width="451" height="39" alt="image" src="https://github.com/user-attachments/assets/e3f5be17-d59e-4d8b-9865-eb2e8bd7a3a3" />

### Configuração do AWS CLI:

- Para instalar o AWS CLI (caso ainda não tenha) em seu Linux é necessário executar esses três comandos em sequência:

<img width="743" height="40" alt="Captura de tela 2025-11-05 173409" src="https://github.com/user-attachments/assets/570e1bc9-c14c-494c-8836-2cd973b48beb" />

<img width="224" height="32" alt="image" src="https://github.com/user-attachments/assets/eccb182d-5df2-4911-970c-729b37c2fc57" />

<img width="194" height="33" alt="image" src="https://github.com/user-attachments/assets/4b05104a-28db-458b-a4ed-9b0c62ec9dd0" />

- Para configurar as credenciais é necessário executar esse comando:

<img width="161" height="28" alt="image" src="https://github.com/user-attachments/assets/d5666e26-b20b-4eda-b614-e316cb112c85" />

Ele irá solicitar 4 informações, o Access Key ID e a Secret Access Key (Geradas no painel de usuário da AWS), A Default region name (Ex.: us-east-1) e a Default output format (Utilizei json).

## 6. Execução do projeto

### Clonagem do repositório

<img width="819" height="36" alt="Captura de tela 2025-11-03 210946" src="https://github.com/user-attachments/assets/b425c250-11e6-4b27-b6bc-963f7467ec82" />

Primeiramente clone esse repositório no Linux para que possa executar o Terraform.

### Inicialização do Terraform

O próximo passo é inicializar o ambiente Terraform com:

<img width="152" height="35" alt="image" src="https://github.com/user-attachments/assets/b3f016af-39b4-4210-9475-29dcb11eb5f6" />

A saída após a inicialização é a seguinte:

<img width="776" height="510" alt="Captura de tela 2025-11-03 211809" src="https://github.com/user-attachments/assets/28e1fa78-b8ab-4269-b142-612cf1e5b1ee" />

Esse comando baixa os provedores da AWS e prepara o ambiente para o provisionamento.

### Plano e Aplicação

Antes de aplicar as mudanças, é possível visualizar o que será criado:

<img width="715" height="35" alt="Captura de tela 2025-11-04 201925" src="https://github.com/user-attachments/assets/d9926d24-583e-493b-bb1a-a30cab25757a" />

Depois, para realmente criar os recursos:

<img width="724" height="35" alt="Captura de tela 2025-11-04 202003" src="https://github.com/user-attachments/assets/9ee85f96-7333-4daa-a1cf-a18f7c1dcf17" />

<img width="687" height="105" alt="Captura de tela 2025-11-04 202018" src="https://github.com/user-attachments/assets/0da036fd-9b2e-4332-b2cb-e1071d4aefe5" />

Retorno após aplicação:

<img width="1054" height="165" alt="image" src="https://github.com/user-attachments/assets/75b566a1-452d-48cb-9f62-172dd9e52598" />

**Diferença**:
- Plan: mostra as alterações que serão feitas.
- Apply: executa o plano e cria os recursos.

## 7. Instância criada com sucesso

Após a execução, o Terraform cria automaticamente a instância EC2.

<img width="1653" height="243" alt="Captura de tela 2025-11-04 202403" src="https://github.com/user-attachments/assets/40520a55-d9af-477a-8574-71604c11d905" />

**Detalhes:**
- Tipo: t3.micro
- Região: us-east-1
- IP público o mesmo exibido no output do Terraform

## 8. Verificando Status do serviço na instância

Com a instância criada vamos conectar à mesma para verificar o status do servidor diretamente no ambiente

<img width="761" height="288" alt="Captura de tela 2025-11-04 202438" src="https://github.com/user-attachments/assets/036d0821-df82-4fdb-ad87-7bc3f8178f13" />

Podemos verificar o status do serviço na instância utilizando esse comando:

<img width="308" height="21" alt="Captura de tela 2025-11-04 212212" src="https://github.com/user-attachments/assets/69a13a5b-64a3-4402-8dfe-656ee051c61b" />

Após utilizar esse comando, é possível verificar que o serviço está ativo através desse retorno:

<img width="1912" height="170" alt="Captura de tela 2025-11-04 212202" src="https://github.com/user-attachments/assets/a8af4273-4231-4705-8eeb-b115db8b9984" />

## 9. API acessível pela EC2

Com a EC2 ativa, a API Flask é iniciada automaticamente pelo user_data e fica disponível pelo IP público da instância.

### Teste através do navegador

A partir da URL com o ip público disponibilizado pelo output do terraform, acessei a API através do navegador, e nele é possível visualizar a API ativa e rodando.

<img width="1719" height="322" alt="Captura de tela 2025-11-04 212610" src="https://github.com/user-attachments/assets/5d5ed16e-9bc8-4773-a7dd-5d714050eec6" />

### Teste utilizando o Postman

Utilizando o postman, é possível inserir a URL da aplicação para fazer requisições http e visualizar as informações dos usuários cadastrados na API em json.

Resposta da rota /users:

<img width="854" height="731" alt="Captura de tela 2025-11-04 212852" src="https://github.com/user-attachments/assets/495bbe26-d6fc-41b4-88f1-51b04be6653e" />

Resposta da rota /users/ID:

<img width="853" height="728" alt="Captura de tela 2025-11-04 213013" src="https://github.com/user-attachments/assets/6bd0e19d-58dc-450d-b22a-316e35e39916" />

## 10. Acessando remotamente a instância

Após verificar a atividade da aplicação, acessei a instância remotamente para verificar os logs da aplicação diretamente pela minha máquina.

É possível acessar através do comando SSH disponibilizado no output do Terraform:

<img width="959" height="118" alt="Captura de tela 2025-11-04 213953" src="https://github.com/user-attachments/assets/054080d8-2495-445c-8a39-0253cd981892" />

Após o comando, acessei a instância EC2 criada diretamente na minha máquina:

<img width="1034" height="376" alt="Captura de tela 2025-11-04 214012" src="https://github.com/user-attachments/assets/4be78783-7122-4b9b-af88-cd2cd08ed91d" />

Após isso, acessei o diretório onde estão os logs da aplicação através do comando:

<img width="438" height="30" alt="Captura de tela 2025-11-04 214054" src="https://github.com/user-attachments/assets/861ae9bf-57a1-47ac-abb9-385ebbaa2bf2" />

### Visualizando os logs de acesso

Já dentro do diretório onde estão os comandos, é possível visualizar os logs de acesso através do comando:

<img width="154" height="22" alt="Captura de tela 2025-11-04 214114" src="https://github.com/user-attachments/assets/9723818a-d0e1-4c50-9eef-b48fdb54ae0a" />

Nele é possível visualizar até mesmo as requisições feitas anteriormente pelo Postman:

<img width="1092" height="137" alt="Captura de tela 2025-11-04 214134" src="https://github.com/user-attachments/assets/453aa1ed-18ad-4655-a83b-59f3092237b2" />

### Visualizando os logs de erro

Além dos logs de acesso, também é possível visualizar os logs da aplicação para ocorrência de possíveis erros através do comando:

<img width="145" height="34" alt="image" src="https://github.com/user-attachments/assets/3870ad3c-b1a3-4cde-830d-f0f22336c3b8" />

Nele é possível verificar que não houve nenhum erro, logo a aplicação registrou a sua inicialização corretamente:

<img width="799" height="102" alt="Captura de tela 2025-11-04 214157" src="https://github.com/user-attachments/assets/8fd128fa-e842-4921-a107-34e6e67e509d" />

## 11. Destruição da Infraestrutura

Para encerrar o ambiente e remover todos os recursos criados é necessário utilizar esse comando no Terraform (Após sair da instância e voltar à pasta em que foi iniciado):

<img width="180" height="33" alt="image" src="https://github.com/user-attachments/assets/7007ad19-4837-4e9a-9b65-1768bfcc2677" />

Após aguardar a devida finalização, esse é o retorno do Terraform:

<img width="386" height="28" alt="Captura de tela 2025-11-04 214645" src="https://github.com/user-attachments/assets/776dc57f-e4f4-470d-8c4b-d21493b2312a" />

O Terraform gerencia todo o ciclo de vida da infraestrutura — criação, alteração e destruição — garantindo um ambiente limpo e controlado.

## 12. Resultados e aprendizados

Este projeto me proporcionou uma visão prática de automação e deploy em nuvem, consolidando conceitos essenciais de Infraestrutura e Cloud.

**Principais aprendizados**
- Conceito e prática de Infraestrutura como Código (IaC)
- Integração entre Terraform e AWS
- Automação de deploys com user_data
- Gerenciamento seguro de chaves e credenciais
- Entendimento dos conceitos fundamentais de Cloud Computing

## Possíveis melhorias

- Adicionar load balancer
- Configurar banco de dados RDS
- Criar pipeline CI/CD para deploy automático
- Implementar monitoramento com CloudWatch

## Tecnologias utilizadas

- Terraform
- AWS EC2
- Python / Flask
- Postman
- Git / GitHub

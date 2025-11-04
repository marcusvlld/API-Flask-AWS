terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# Pega a AMI Amazon Linux 2 (compatível e leve)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Importa a public key local e cria um key pair na AWS
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

# Security Group: SSH e porta 5000 (Flask)
resource "aws_security_group" "sg_api" {
  name        = "userinfoapi-sg"
  description = "Allow SSH and Flask port"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask app port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-userinfoapi"
  }
}

# Pega o default VPC (para evitar criar/gerenciar VPC)
data "aws_vpc" "default" {
  default = true
}



data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Cria uma instância EC2
resource "aws_instance" "api_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.sg_api.id]
  subnet_id                   = element(data.aws_subnets.default_subnets.ids, 0)
  associate_public_ip_address = true

  # user_data instala dependências, clona repo e inicia app via systemd
  user_data = templatefile("${path.module}/user_data.tpl", {
  github_repo = var.github_repo
  APP_DIR     = "/opt/userinfoapi"
  SERVICE_FILE = "/etc/systemd/system/userinfoapi.service"
})

  tags = {
    Name = "UserInfoAPI-Server"
  }
}

# Espera até SSH estar disponível (ajuda no apply)
resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.api_server]

  provisioner "local-exec" {
    command = "echo 'EC2 criada. IP: ${aws_instance.api_server.public_ip}'"
  }
}

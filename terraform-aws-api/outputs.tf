output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api_server.public_ip
}

output "ssh_command" {
  description = "Comando SSH para conectar"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.api_server.public_ip}"
}

output "test_url" {
  description = "URL para testar a API"
  value       = "http://${aws_instance.api_server.public_ip}:5000/"
}

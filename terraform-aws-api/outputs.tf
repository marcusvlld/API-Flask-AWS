output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.api_server.public_ip
}

output "ssh_command" {
  description = "SSH command to connect (use your private key)"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.api_server.public_ip}"
}

output "test_url" {
  description = "URL to test the app"
  value       = "http://${aws_instance.api_server.public_ip}:5000/"
}

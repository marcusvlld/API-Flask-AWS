variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Path to your local SSH public key file (e.g. ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "github_repo" {
  description = "Git repo URL containing your Flask app (HTTPS). Should have app.py and requirements.txt in repo root"
  type        = string
  default     = "https://github.com/marcusvlld/API-Flask-AWS.git"
}

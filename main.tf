
# Create private key locally
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key to AWS as a Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Security group to allow SSH and HTTP
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y
              echo "Terraform Learning..!" > /var/www/html/index.html
              systemctl restart nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = var.instance_name
  }
}

# Save private key locally (Optional)
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/private_key.pem"
  file_permission = "0400"
}

# Output public IP and SSH command
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "ssh_command" {
  value = "ssh -i private_key.pem ubuntu@${aws_instance.web.public_ip}"
}
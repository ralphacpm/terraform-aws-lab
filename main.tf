terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 4.0"        # Use a version of the AWS provider that is compatible with version
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

# 1. Create a Security Group (Firewall)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins Traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow Jenkins from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow server to talk to the internet
  }
}

# 2. Create the Server with the Setup Script
resource "aws_instance" "my_server" {
  ami                    = "ami-04b70fa74e45c3917" # Ubuntu 24.04 (us-east-1)
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "n-virginia" # <--- MAKE SURE THIS MATCHES YOUR AWS KEY PAIR NAME

  tags = {
    Name = "Jenkins-Terraform-Server"
  }

  # This script runs ONCE when the server starts
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install openjdk-17-jre -y
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update -y
              sudo apt install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

resource "aws_security_group" "jenkins_server" {
  name = "Jenkins Server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow Jenkins from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow server to talk to the internet
  }
}

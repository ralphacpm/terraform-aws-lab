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

resource "aws_instance" "my_server" {
  ami           = "ami-04b70fa74e45c3917"  # Ubuntu 24.04 (us-east-1). CHANGE THIS if you use a different region.
  instance_type = "t3.medium"

  tags = {
    Name = "terraform-local-machine"
  }
}

# Provider configuration for AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQE3ROP4NRMIJOCU"
  secret_key = "ZcKFoBvunY1Ken4/W0pIZvVaaixCcIO/3Q278W7"
}

# Terraform block to specify required providers
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Generate an RSA private key
resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Variable for key name
variable "key_name" {
  default = "deployer-key.pem" # Specify a default filename for the private key
}

# Create AWS key pair using the public key from the generated private key
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name  # Referencing the variable key_name here
  public_key = tls_private_key.example_key.public_key_openssh  
}

# Save the private key to a local .pem file
resource "local_file" "private_key" {
  content  = tls_private_key.example_key.private_key_pem 
  filename = var.key_name
}

# Launch an EC2 instance
resource "aws_instance" "public_instance" {
  ami           = "ami-0866a3c8686eaeba"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name  

  tags = {
    Name = "public_instance"
  }
}


# destroy
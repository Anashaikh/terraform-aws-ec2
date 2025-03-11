terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
 
  backend "s3" {
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
 


# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # Replace with your desired CIDR
  tags = {
    Name = "My VPC"
  }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24" # Replace with your desired CIDR
  tags = {
    Name = "My Subnet"
  }
}

# Security Group
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "example" {
     ami           = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro" # Replace with your desired instance type
  subnet_id                   = aws_subnet.main.id # Reference the subnet ID
  vpc_security_group_ids      = [aws_security_group.example.id] # Reference the security group
  tags = {
    Name = "My EC2 Instance"
  }
}

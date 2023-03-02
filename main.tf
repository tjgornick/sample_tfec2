## sample_tfec2
## A working AWS EC2 web server in 5 minutes or less

# Set explicit (working) versions
terraform {
  required_version = ">= 1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

# Create VPC
resource "aws_vpc" "sample_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "sample_subnet" {
  vpc_id                  = aws_vpc.sample_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Query most recent Amazon Linux 2 AMI
data "aws_ami" "amzlinux2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create EC2 keypair for ssh access via locally created keypair
resource "aws_key_pair" "sample_key_pair" {
  key_name   = "sample_key_pair_name"
  public_key = file("${var.sample_key_pair_pub}")
}

# Create security group for web and SSH access
resource "aws_security_group" "sample_sg_http_ssh" {
  name        = "sample_sg_http_ssh"
  description = "allow http, ssh traffic in, all out"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

# Create EC2 instance 
resource "aws_instance" "sample_ec2_instance" {
  ami           = data.aws_ami.amzlinux2_latest.image_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.sample_key_pair.key_name
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 1
    volume_type = "gp2"
  }
  security_groups = ["sample_sg_http_ssh"]
  user_data       = file("${var.sample_ec2_provision_script}")
}

output "sample_ec2_instance_public_dns" {
  value = aws_instance.sample_ec2_instance.public_dns
}

output "sample_ec2_instance_public_ip" {
  value = aws_instance.sample_ec2_instance.public_ip
}

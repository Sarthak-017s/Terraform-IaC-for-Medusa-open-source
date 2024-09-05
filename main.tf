terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.59.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "medusa_vpc" {
  cidr_block = "10.0.0.0/16"
}


# Create Subnet
resource "aws_subnet" "medusa_subnet" {
  vpc_id            = aws_vpc.medusa_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "medusa_subnet2" {
  vpc_id            = aws_vpc.medusa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create Security Group
resource "aws_security_group" "medusa_sg" {
  name        = "medusa_sg"
  description = "Allow inbound traffic on port 80 and 443"
  vpc_id      = aws_vpc.medusa_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create EC2 Instance
resource "aws_instance" "medusa_instance" {
  ami           = "ami-0e86e20dae9224db8" # Replace with Medusa-compatible AMI
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.medusa_sg.id]
  subnet_id = aws_subnet.medusa_subnet.id
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "medusa_db_subnet_group" {
  name       = "medusa_db_subnet_group"
  subnet_ids = [aws_subnet.medusa_subnet.id]
}

# Create RDS Instance
resource "aws_db_instance" "medusa_db" {
  engine         = "postgres"
  engine_version = "12.4"
  instance_class = "db.t2.micro"
  username       = var.db_username
  password       = var.db_password
  vpc_security_group_ids = [aws_security_group.medusa_sg.id]
  db_subnet_group_name = aws_db_subnet_group.medusa_db_subnet_group.name
}



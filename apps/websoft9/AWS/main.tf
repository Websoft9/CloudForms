provider "aws" {
  region     = "us-east-1"
  access_key = "aws_access_key"
  secret_key = "aws_secret_key"
}
# Create a VPC
resource "aws_vpc" "websoft9_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Create an Internet Gateway
resource "aws_internet_gateway" "websoft9_igw" {
  vpc_id = aws_vpc.websoft9_vpc.id
}
# Create a Subnet
resource "aws_subnet" "websoft9_subnet" {
  vpc_id            = aws_vpc.websoft9_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
# Create a Route Table and associate it with the Subnet
resource "aws_route_table" "websoft9_route_table" {
  vpc_id = aws_vpc.websoft9_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.websoft9_igw.id
  }
}
resource "aws_route_table_association" "websoft9_route_table_assoc" {
  subnet_id      = aws_subnet.websoft9_subnet.id
  route_table_id = aws_route_table.websoft9_route_table.id
}
# Create a Security Group with inbound and outbound rules
resource "aws_security_group" "websoft9_sg" {
  vpc_id = aws_vpc.websoft9_vpc.id
  # Inbound rules
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
  ingress {
    from_port   = 9000
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create an EC2 instance
resource "aws_instance" "websoft9_ec2" {
  ami                         = "ami-09b57783022faa8d3"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.websoft9_subnet.id
  vpc_security_group_ids      = [aws_security_group.websoft9_sg.id]
  associate_public_ip_address = true
  key_name                    = "websoft9-keypair"
  tags = {
    Name = "Websoft9 ESC Instance"
  }
}

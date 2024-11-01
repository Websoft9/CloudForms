# main.tf
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "rabbitmq-vpc"
  }
}

# Subnets
resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr_primary
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "rabbitmq-primary-subnet"
  }
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr_secondary
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "rabbitmq-secondary-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "rabbitmq-igw"
  }
}

# Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "rabbitmq-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "primary_subnet_association" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "secondary_subnet_association" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Security Group
resource "aws_security_group" "rabbitmq_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow RabbitMQ traffic"

  ingress {
    description = "AMQP Protocol"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RabbitMQ Management UI"
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify to restrict access if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "rabbitmq_cluster" {
  name = "rabbitmq-cluster"
}

# ECS Task Definition for RabbitMQ
resource "aws_ecs_task_definition" "rabbitmq_task" {
  family                   = "rabbitmq"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.instance_memory
  cpu                      = var.instance_cpu

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = "rabbitmq:3-management"
      essential = true
      environment = [
        { name = "RABBITMQ_ERLANG_COOKIE", value = var.rabbitmq_erlang_cookie },
        { name = "RABBITMQ_DEFAULT_USER", value = var.rabbitmq_admin_user },
        { name = "RABBITMQ_DEFAULT_PASS", value = var.rabbitmq_admin_pass }
      ]
      portMappings = [
        {
          containerPort = 5672
          hostPort      = 5672
        },
        {
          containerPort = 15672
          hostPort      = 15672
        }
      ]
    }
  ])
}

# ECS Service for Primary Node
resource "aws_ecs_service" "primary_service" {
  name            = "rabbitmq-primary"
  cluster         = aws_ecs_cluster.rabbitmq_cluster.id
  task_definition = aws_ecs_task_definition.rabbitmq_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.primary_subnet.id]
    security_groups  = [aws_security_group.rabbitmq_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "rabbitmq-primary-service"
  }
}

# ECS Service for Secondary Node
resource "aws_ecs_service" "secondary_service" {
  name            = "rabbitmq-secondary"
  cluster         = aws_ecs_cluster.rabbitmq_cluster.id
  task_definition = aws_ecs_task_definition.rabbitmq_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.secondary_subnet.id]
    security_groups  = [aws_security_group.rabbitmq_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "rabbitmq-secondary-service"
  }
}

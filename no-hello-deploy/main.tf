provider "aws" {
  region = "us-west-1"
}

locals {
  app_name = "no-hello-bot"
}

resource "aws_security_group" "allow_http" {
  name        = "${local.app_name}-http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = local.app_name
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = local.app_name
  }
}

resource "aws_kms_key" "main" {
  description = "${local.app_name} KMS Key"
}

resource "aws_ecr_repository" "main" {
  name = local.app_name
}

module "fargate" {
  source  = "terraform-aws-modules/ecs/aws//modules/fargate-service"

  name_prefix   = local.app_name
  ecs_cluster_arn = aws_ecs_cluster.main.arn

  task_definition_json = jsonencode({
    family = local.app_name
    containerDefinitions = [
      {
        name      = local.app_name
        image     = "${aws_ecr_repository.main.repository_url}:latest"
        essential = true
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ]
        environment = [
          {
            name  = "BOT_TOKEN"
            value = aws_kms_key.main.arn
          }
        ]
      }
    ]
  })

  security_group_ids = [aws_security_group.allow_http.id]
  subnet_ids         = aws_subnet.main.id

  load_balancer_arn = aws_lb.main
}

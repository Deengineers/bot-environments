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

resource "aws_ecs_cluster" "main" {
  name = local.app_name
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
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
          name  = "TOKEN"
          value = aws_kms_key.main.arn
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.app_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.app_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_ecs_service" "main" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }
}
resource "aws_iam_policy" "cloud_user_policy" {
  name        = "CloudUserPolicy"
  description = "Policy with necessary permissions for cloud_user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateSecurityGroup",
          "ec2:CreateVpc",
          "kms:CreateKey",
          "ecr:CreateRepository",
          "ecs:CreateCluster",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:DeregisterTaskDefinition",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVpc",
          "kms:DeleteKey",
          "ecr:DeleteRepository",
          "ecs:DeleteCluster",
          "iam:DetachRolePolicy",
          "iam:DeleteRole"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_user_policy_attachment" "cloud_user_policy_attachment" {
  policy_arn = aws_iam_policy.cloud_user_policy.arn
  user       = "cloud_user"
}




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


# module "fargate" {
#   source  = "terraform-aws-modules/ecs/aws//modules/fargate-service"

#   name_prefix   = local.app_name
#   ecs_cluster_arn = aws_ecs_cluster.main.arn

#   task_definition_json = jsonencode({
#     family = local.app_name
#     containerDefinitions = [
#       {
#         name      = local.app_name
#         image     = "${aws_ecr_repository.main.repository_url}:latest"
#         essential = true
#         portMappings = [
#           {
#             containerPort = 80
#             hostPort      = 80
#           }
#         ]
#         environment = [
#           {
#             name  = "TOKEN"
#             value = aws_kms_key.main.arn
#           }
#         ]
#       }
#     ]
#   })

#   security_group_ids = [aws_security_group.allow_http.id]
#   subnet_ids         = aws_subnet.main.id

#   load_balancer_arn = aws_lb.main
# }

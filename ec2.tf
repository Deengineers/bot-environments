resource "aws_instance" "discord_bot" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  key_name = aws_key_pair.id_rsa.key_name
  #   security_groups        = [aws_security_group.allow_ssh.name]
  subnet_id              = aws_subnet.discord_bot_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y yum-utils
              sudo yum install -y amazon-ec2-instance-connect
              sudo yum install -y docker python3 golang
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              sudo git clone https://github.com/Deengineers/no-hello-bot.git
              sudo git clone https://github.com/Deengineers/discord-job-bot
              EOF

  tags = {
    Name = "discord_bot"
  }
}

resource "aws_iam_role_policy_attachment" "instance_connect_policy_attachment" {
  policy_arn = aws_iam_policy.instance_connect_policy.arn
  role       = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_policy" "instance_connect_policy" {
  name        = "InstanceConnectPolicy"
  description = "Allows EC2 Instance Connect"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2-instance-connect:SendSSHPublicKey"
        Effect = "Allow"
        Resource = [
          "arn:aws:ec2:*:*:instance/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}
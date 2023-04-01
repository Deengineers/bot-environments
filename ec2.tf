resource "aws_instance" "discord_bot" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 LTS AMI
  instance_type = "t2.micro"

  key_name          = aws_key_pair.discord_bot_key.key_name
  security_groups   = [aws_security_group.allow_ssh.name]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker python3 golang
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = {
    Name = "discord_bot"
  }
}
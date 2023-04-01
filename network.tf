resource "aws_vpc" "bot" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "discord_bot_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.bot.id

  map_public_ip_on_launch = true

  tags = {
    Name = "discord_bot_subnet"
  }
}

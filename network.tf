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

resource "aws_eip" "example" {
  vpc      = true
  instance = aws_instance.discord_bot.id

  depends_on = [
    aws_internet_gateway.gateway
  ]

  tags = {
    Name = "example_eip"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.bot.id

  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.bot.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  depends_on = [
    aws_eip.example
  ]

  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.discord_bot_subnet.id
  route_table_id = aws_route_table.example.id

  depends_on = [
    aws_route_table.example
  ]
}
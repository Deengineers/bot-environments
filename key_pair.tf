resource "aws_key_pair" "discord_bot_key" {
  key_name   = "discord_bot_key"
  public_key = file("~/.ssh/aws_pair.pub")
}
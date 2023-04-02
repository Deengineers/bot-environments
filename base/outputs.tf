output "discord_bot_public_ip" {
  description = "The public IP address of the Discord Bot EC2 instance"
  value       = aws_instance.discord_bot.public_ip
}
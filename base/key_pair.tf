resource "aws_key_pair" "id_rsa" {
  key_name = "id_rsa"
  #   public_key = file("~/.ssh/id_rsa.pub") >> FOR LOCAL ONLY
  public_key = var.public_key # for GHA
}
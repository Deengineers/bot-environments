resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = file("../aws_key_pem.pub")
}
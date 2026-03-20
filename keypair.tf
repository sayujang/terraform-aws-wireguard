resource "aws_key_pair" "vpn-kp" {
  key_name   = "vpn-key"
  public_key = file("~/.ssh/testkey.pub")

}
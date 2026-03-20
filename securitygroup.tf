resource "aws_security_group" "vpnsg" {
  name        = "vpn-sg"
  description = "vpn-sg"

  tags = {
    Name = "vpn-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_myip" {
  security_group_id = aws_security_group.vpnsg.id
  cidr_ipv4         = "116.66.195.245/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "wireguard_udp" {
  security_group_id = aws_security_group.vpnsg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 51820
  ip_protocol       = "udp"
  to_port           = 51820
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vpnsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.vpnsg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
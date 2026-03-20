resource "aws_instance" "name" {
  ami                    = data.aws_ami.amiID.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vpn-kp.key_name
  vpc_security_group_ids = [aws_security_group.vpnsg.id]
  availability_zone      = var.zone
  tags = {
    Name    = "web_instance"
    Project = "VPN"
  }
  provisioner "file" {
    source      = "vpn_provision.sh"
    destination = "/tmp/vpn_provision.sh"
  }
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file("~/.ssh/testkey")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/vpn_provision.sh",
      "sudo /tmp/vpn_provision.sh",
      "sudo cp /root/client.conf /home/ubuntu/client.conf",
      "sudo chown ubuntu:ubuntu /home/ubuntu/client.conf"
    ]
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/testkey ${var.user}@${self.public_ip}:/home/ubuntu/client.conf ./client.conf"
  }
}
resource "aws_ec2_instance_state" "web_state" {
  instance_id = aws_instance.name.id
  state       = "running" # or "stopped"
}

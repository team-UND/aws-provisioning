resource "aws_instance" "bastion_ec2" {
  ami                         = "ami-0662f4965dfc70aca" # Ubuntu Server 24.04 LTS (HVM)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion_ec2_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true

  tags = {
    Name = "bastionec2-${var.vpc_name}"
  }
}

resource "terraform_data" "copy_key" {
  depends_on = [aws_instance.bastion_ec2, local_file.private_ec2_key]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.bastion_ec2.public_ip
    private_key = tls_private_key.ec2_key_pair[0].private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ubuntu/keys"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/${local_file.private_ec2_key.filename}"
    destination = "/home/ubuntu/keys/${local_file.private_ec2_key.filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/keys/${local_file.private_ec2_key.filename}"
    ]
  }
}

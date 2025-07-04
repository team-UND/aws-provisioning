# Key pair
resource "tls_private_key" "ec2_key_pair" {
  count     = 2
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "bastion_ec2_key" {
  key_name   = var.bastion_ec2_key_name
  public_key = tls_private_key.ec2_key_pair[0].public_key_openssh
}

resource "local_file" "bastion_ec2_key" {
  filename        = var.bastion_ec2_key_name
  file_permission = "0600"
  content         = tls_private_key.ec2_key_pair[0].private_key_pem
}

resource "aws_key_pair" "private_ec2_key" {
  key_name   = var.private_ec2_key_name
  public_key = tls_private_key.ec2_key_pair[1].public_key_openssh
}

resource "local_file" "private_ec2_key" {
  filename        = var.private_ec2_key_name
  file_permission = "0600"
  content         = tls_private_key.ec2_key_pair[1].private_key_pem
}

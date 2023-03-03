provider "aws" {
  region  = var.default-region
  profile = var.aws-profile
}

data "aws_ami" "ubuntu-20-lts" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }

}
resource "aws_instance" "k8s-nodes" {
  ami                         = data.aws_ami.ubuntu-20-lts.id
  instance_type               = var.node-instance-type
  associate_public_ip_address = true
  key_name                    = "k8s-test-cluster"

  for_each = var.cluster-node-names

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_eighty.id
  ]

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${each.value}"]
  }

  tags = {
    Name = each.value
  }

}

# Get object data about default VPC
data "aws_vpc" "default-vpc" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default-vpc.id

  ingress {
    description = "SSH from/to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default-vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_eighty" {
  name        = "allow_eighty"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default-vpc.id

  ingress {
    description = "HTTP from/to VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default-vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_eighty"
  }
}


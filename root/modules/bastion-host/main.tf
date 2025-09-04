resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    coalesce(var.security_group_id, aws_security_group.bastion.id)
  ]
  key_name = var.key_name
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-${var.instance_name}"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_security_group" "bastion" {
  name        = "Soquiat-FinalProject-BastionSG"
  description = "Allow SSH Access to Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}
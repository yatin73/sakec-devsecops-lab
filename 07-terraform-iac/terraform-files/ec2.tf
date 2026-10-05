# Latest Ubuntu 22.04 LTS AMI, looked up dynamically (don't hardcode AMI IDs - they change per region/date)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "lab_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name = "sakec-devsecops-ec2-tf"
  }
}

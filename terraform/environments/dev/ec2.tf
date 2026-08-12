resource "aws_security_group" "ec2_ssh_access" {
    name = "ec2-ssh-access"
    description = "Allow SSH access"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-00000001"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_ssh_access.id]

  tags = {
    Name = "finflow-bastion"
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file("~/.ssh/id_rsa.pub")  # Update with your local public key path
}

resource "aws_security_group" "ansible_sg" {
  name        = "ansible_sg"
  description = "Allow SSH and HTTP"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_server" {
  ami           = "ami-04a81a99f5ec58529"  # Update with the latest Ubuntu AMI ID for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.ansible_sg.name]

  tags = {
    Name = "AnsibleServer"
  }
}

resource "aws_instance" "target_instance" {
  count         = 3  # Number of target instances
  ami           = "ami-04a81a99f5ec58529"  # Update with the latest Ubuntu AMI ID for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.ansible_sg.name]

  tags = {
    Name = "TargetInstance${count.index + 1}"
  }
}

output "ansible_server_ip" {
  value = aws_instance.ansible_server.public_ip
}

output "target_instance_ips" {
  value = aws_instance.target_instance[*].public_ip
}

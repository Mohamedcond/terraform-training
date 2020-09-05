provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWEVOOKKS7J25DFGQ"
  secret_key = "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"
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "myec2" {
  ami             = data.aws_ami.app_ami.id
  instance_type   = var.instancetype
  key_name        = "devops-mohamed"
  tags            = var.aws_common_tag
  security_groups = ["${aws_security_group.allow_ssh_http_https.name}"]

  provisioner "remote-exec" {
     inline = [
       "sudo mkdir -p /var/www/html/",
       "sudo yum install -y httpd",
       "sudo service httpd start",
       "sudo usermod -a -G apache ec2-user",
       "sudo chown -R ec2-user:apache /var/www",
     ]

   connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("./devops-mohamed.pem")
     host = self.public_ip
   }
   }
   root_block_device {
    delete_on_termination = true   # effacer toutes les ressources
  }

}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "mohamed-sg"
  description = "Allow http and https inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
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

resource "aws_eip" "lb" {
  instance = aws_instance.myec2.id
  vpc      = true
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${aws_eip.lb.public_ip} ; ID: ${aws_instance.myec2.id} ; AZ: ${aws_instance.myec2.availability_zone}; >> infos_ec2.txt"
  }
}

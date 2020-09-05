provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "myec2" {
  ami           = "ami-0083662ba17882949"
  instance_type = "t2.micro"
  key_name      = "devops-mohamed"
  tags = {
    Name = "ec2-mohamed"
  }
  root_block_device {
    delete_on_termination = true
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-conde"
    key    = "mohamed.tfstate"
    region = "us-east-1"
    access_key = ""
    secret_key = ""
  }
}

module "ec2" {
  source = "../modules/ec2module"
  instancetype = "t2.nano"
  aws_common_tag = {
    Name = "ec2-dev-mohamed"
  }
  sg_name = "dev-mohamed-sg"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.0"

  name = "jenkins"

  cidr            = "10.0.0.0/16"
  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
#   private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false

  create_database_subnet_group = false

  tags = {
    Environment = "Development"
  }
}

resource "aws_security_group" "asg" {
  name              = "ASG-SG"
  description       = "Allow jenkins master traffic get through"  
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["58.164.52.9/32"]
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "ASG-SG"
  }
}
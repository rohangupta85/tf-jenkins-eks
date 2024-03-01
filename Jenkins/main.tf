#VPC creation
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc" #optional but good to have ofcourse
  cidr = var.vpc_cidr  #this is the only necessary field

  azs                     = data.aws_availability_zones.azs.names
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true #VERY IMPORTANT to not miss this 

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }

  #IGW, RTB, RTA - everything is taken care of for us by this module!

}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "SG for Jenkins server"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Jenkins from my IP only 8080"
      cidr_blocks = "96.240.11.71/32"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from my IP address only"
      cidr_blocks = "96.240.11.71/32"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

#ec2 module

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-ec2"

  instance_type          = var.instance_type
  key_name               = "TerraformNEWrg"
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id] #check output from the SG module documentation. Terraform documentation says this_security_group_id which is INCORRECT!!
  subnet_id              = module.vpc.public_subnets[0]  #This will return a list, we just need to fetch the first item

  associate_public_ip_address = true

  user_data = file("jenkins-install.sh") #passing this file to install jenkins, terraform, git and kubectl on the ec2 instance

  availability_zone = data.aws_availability_zones.azs.names[0] #creating this instance in the first AZ from the list of AZs

  tags = {
    Name        = "jenkins-ec2"
    Terraform   = "true"
    Environment = "dev"
  }
}


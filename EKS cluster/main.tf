#VPC creation
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"    #optional but good to have ofcourse
  cidr = var.vpc_cidr #this is the only necessary field

  azs            = data.aws_availability_zones.azs.names
  public_subnets = var.public_subnets
  #map_public_ip_on_launch = true        #Not needed

  enable_dns_hostnames = true

  private_subnets    = var.private_subnets #since we want to create our cluster in a private subnet -- node groups will be in priv subnet
  enable_nat_gateway = true

  #IGW, RTB, RTA - everything is taken care of for us by this module!

  #Need to make sure these tags are in place!
  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1 #note - internal ELB
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id          #getting VPC ID from the VPC module
  subnet_ids = module.vpc.private_subnets #getting private subnet from the VPC module

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = ["t2.small"]
      #capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


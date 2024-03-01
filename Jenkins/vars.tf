variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24"]

}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
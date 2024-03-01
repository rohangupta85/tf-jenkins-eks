terraform {
  backend "s3" {
    bucket = "tf-remote-backend-s3"
    key    = "eks/terraform.tfstate" #Terraform will create the folder called eks in the bucket as long as the terraform user has S3 permissions
    region = "us-east-1"
  }
}
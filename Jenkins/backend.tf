terraform {
  backend "s3" {
    bucket = "tf-remote-backend-s3"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}
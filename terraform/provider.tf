provider "aws" {
    region = "ap-south-1"
}
 
terraform {
    backend "s3" {
      region = "ap-south-1"
      bucket = "tarundanda147"
      key = "state.tfstate"
    }
}

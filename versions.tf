terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["C:/Users/Eishan.Rana/Desktop/repos/project-site-terraform/creds.txt"]
  region = "ca-central-1"
}

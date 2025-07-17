terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region                   = "ca-central-1"
  shared_credentials_files = ["C:/Users/Eishan.Rana/Desktop/repos/project-site-terraform/creds.txt"]
}

locals {
  vms = [
    {
      name              = "ps-release-can-ec2-fastapi"
      vpc_name          = "ps-release-can-vpc-001"
      subnet_id         = module.release_network.subnet_ids["ps-release-can-subnet-001"]
      security_group_id = module.release_network.security_group_ids["ps-release-can-sg-shared"]
      tier              = "app"
    },
    {
      name              = "ps-release-can-ec2-nginx"
      vpc_name          = "ps-release-can-vpc-001"
      subnet_id         = module.release_network.subnet_ids["ps-release-can-subnet-002"]
      security_group_id = module.release_network.security_group_ids["ps-release-can-sg-reserve"]
      tier              = "web"
    },
  ]
}

module "release_vms" {
  source = "./modules/compute"

  vpc     = local.vpc
  subnets = module.release_network.subnets
  vms     = local.vms
}

# import has to be in root module - will remove after its been removed
import {
  to = module.release_vms.aws_key_pair.logger
  id = "project-site-logger" # "key-0588b2a6399ba705d"  
}


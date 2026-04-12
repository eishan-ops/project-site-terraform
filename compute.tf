locals {
  vms = [
    {
      name              = "fastapi-ps-release-can-ec2"
      vpc_name          = "ps-release-can-vpc-001"
      subnet_id         = module.release_network.subnet_ids["ps-release-can-subnet-001"]
      security_group_id = module.release_network.security_group_ids["ps-release-can-sg-shared"]
      tier              = "app"
    },
    {
      name              = "nginx-ps-release-can-ec2"
      vpc_name          = "ps-release-can-vpc-001"
      subnet_id         = module.release_network.subnet_ids["ps-release-can-subnet-002"]
      security_group_id = module.release_network.security_group_ids["ps-release-can-sg-reserve"]
      tier              = "web"
    },
    {
      name              = "ansible-ps-release-can-ec2"
      vpc_name          = "ps-release-can-vpc-002"
      subnet_id         = module.release_network.subnet_ids["ps-release-can-subnet-002"]
      security_group_id = module.release_network.security_group_ids["ps-release-can-sg-reserve"]
      tier              = "management"
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
# import {
#   to = module.release_vms.aws_key_pair.logger
#   id = "logger" # "key-0588b2a6399ba705d"  
# }


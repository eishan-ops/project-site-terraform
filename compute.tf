module "release_vms" {
  source = "./modules/compute"
  
}

# import has to be in root module - will remove after its been removed
import {
  to = module.release_vms.aws_key_pair.logger
  id = "project-site-logger" # "key-0588b2a6399ba705d"  
}

# ######
# # security groups 

# resource "aws_security_group" "allow_tls" {
#   for_each = { for vpc in var.vpc : vpc.name => vpc 
#     for vpc.security_groups
#    }
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   vpc_id      = aws_vpc.main.id

#   tags = {
#     Name = "allow_tls"
#   }
# }
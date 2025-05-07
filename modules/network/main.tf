# resource "aws_vpc" "ps_release_can_vpc_001" {
#   cidr_block       = "10.0.0.0/22"
#   instance_tenancy = "default"
  
#   tags = {
#     Name = "ps-release-can-vpc-001"
#     Managed-By = "terraform"
#     Env = "release"
#   }
# }

# resource "aws_subnet" "ps_release_can_subnet" {
#   vpc_id     = aws_vpc.ps_release_can_vpc_001.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Managed-By = "terraform"
#     Env = "release"
#   }
# }


# for this to work we will need 
# vpc {
#     snet1 = {

#     }

#     snet2 = {

#     }
# }

#naming convention 

# project-env-region-resource--purpose,number

# Examples 

# project-site-release-canadacentral-vpc
# project-site-release-canadacentral-ec2-web001


/*

a general structure I follow when working with nested locals variables:
top level var is going to be a list/tuple [], 
inside of this is going to be a dictionary/map {},
so in combination it looks like [ {}, {}, {} ]
this is followed by flatten *if there are more nests inside the *dict/map
the flatten function strives to make a data structure the same way as above [ {}, {}, {} ]

when making actual resource I follow :
for_each = { for vpc in local.vpcs : vpcs.name => vpc }   # every {} block now gets a key vpcs.name Eg: key: "ps-release-can-vpc-001"
and 'vpc' itself is the entire {} block
values can be accessed by each.key and each.value.cidr_block <-- Eg. 

*/

locals {
  vpc = [
    {
      name = "ps_release_can_vpc_001"
      cidr_block = "10.0.0.0/22"
      attach_internet_gateway = true
      attach_route_table = true
      subnets = [
        {
          name = "ps-release-can-subnet-001"
          cidr_block = "10.0.0.0/25"
        },
        {
          name = "ps-release-can-subnet-002"
          cidr_block = "10.0.1.0/25"
        }
      ]
    },
  ]
}

module "release_network" {
  source = "./modules/network"

  vpc = local.vpc
}

output "subnets" {
  value = module.release_network.subnets
}
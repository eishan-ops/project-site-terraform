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
      name                    = "ps-release-can-vpc-001"
      cidr_block              = "10.0.0.0/22"
      attach_internet_gateway = true
      attach_route_table      = true
      security_groups         = ["ps-release-can-sg-shared", "ps-release-can-sg-reserve"] # shared, # reserve # example 
      subnets = [
        {
          name          = "ps-release-can-subnet-001"
          cidr_block    = "10.0.0.0/25"
          public_subnet = true
          tier          = "app"
        },
        {
          name          = "ps-release-can-subnet-002"
          cidr_block    = "10.0.1.0/25"
          public_subnet = true
          tier          = "web"
        }
      ]
    },
  ]

  security_group_rules = {
    "ps-release-can-sg-shared" = [
      {
        name        = "home-to-fastapi"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 8000
        to_port     = 8000
      },
      {
        name        = "office-to-fastapi"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 8000
        to_port     = 8000
      },
      {
        name        = "home-to-nginx"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 80
        to_port     = 80
      },
      {
        name        = "office-to-nginx"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 80
        to_port     = 80
      },
      {
        name        = "home-to-ssh"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      },
      {
        name        = "office-to-ssh"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      }
    ],
    "ps-release-can-sg-reserve" = [
      {
        name        = "home-to-fastapi"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 8000
        to_port     = 8000
      },
      {
        name        = "office-to-fastapi"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 8000
        to_port     = 8000
      },
      {
        name        = "home-to-nginx"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 80
        to_port     = 80
      },
      {
        name        = "office-to-nginx"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 80
        to_port     = 80
      },
      {
        name        = "home-to-ssh"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      },
      {
        name        = "office-to-ssh"
        cidr_ipv4   = "x.x.x.x"
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      }
    ],
  }

}

module "release_network" {
  source = "./modules/network"

  vpc                  = local.vpc
  security_group_rules = local.security_group_rules
}

output "subnets" {
  value = module.release_network.subnets
}
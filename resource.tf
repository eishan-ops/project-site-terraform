locals {

  vpc = [
    {
      name = "ps_release_can_vpc_001"
      cidr_block = "10.0.0.0/22"
      subnets = [
        {
          name = "ps-release-can-subnet-001"
          cidr_block = "10.0.0.0/25"
        },
        {
          name = "ps-release-can-subnet-002"
          cidr_block = "10.0.1.0/25"
        },
      ]
    },
  ]

  flat_subnets = flatten([for vpc in local.vpc : [
    for subnet in vpc.subnets : {
      name = subnet.name
      cidr_block = subnet.cidr_block
      vpc_id = aws_vpc.main[vpc.name].id
    }
  ]
  ])
}

output "subnets" {
  value = local.flat_subnets
}

resource "aws_vpc" "main" {
  for_each = { for vpc in local.vpc : vpc.name => vpc }
  cidr_block       = each.value.cidr_block
  instance_tenancy = "default"
  
  tags = {
    Name = each.key
    Managed-By = "terraform"
    Env = "release"
  }
}

resource "aws_subnet" "main" {
  for_each   = { for subnet in local.flat_subnets : subnet.name => subnet }
  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
    Managed-By = "terraform"
    Env = "release"
  }
}


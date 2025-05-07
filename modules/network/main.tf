locals {

  flat_subnets = flatten([ for vpc in var.vpc : [
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
  for_each = { for vpc in var.vpc : vpc.name => vpc }
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


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

resource "aws_internet_gateway" "main" {
  for_each = { for vpc in var.vpc : vpc.name => vpc 
  if lookup(vpc, "attach_internet_gateway", null)
    }
  vpc_id = aws_vpc.main[each.key].id
}

resource "aws_route_table" "main" {
  for_each = { for vpc in var.vpc : vpc.name => vpc
  if lookup(vpc, "attach_route_table", null)
   }
  vpc_id = aws_vpc.main[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[each.key].id
  }
}
locals {

  flat_subnets = flatten([ for vpc in var.vpc : [
    for subnet in vpc.subnets : {
      name = subnet.name
      cidr_block = subnet.cidr_block
      vpc_name = vpc.name
      vpc_id = aws_vpc.main[vpc.name].id
      public_subnet = subnet.public_subnet
      tier = subnet.tier
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
    public_subnet = each.value.public_subnet
    tier = each.value.tier
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

### In the below resource , please notice that the route table resource above is keyed using vpc.name 
### So we have to have vpc name in our flat subnets struct
### Then with the flat subnets struct, we check if public subnet == true AND keys of RTB resource above(which is vpc.name) - basically checking which VPCs have RTBs
### in the last line of the resource below, we have to get the RTB IDs via. vpc.name , because of all above stated reasons.

resource "aws_route_table_association" main {
  for_each = { for subnet in local.flat_subnets : subnet.name => subnet
  if subnet.public_subnet == true && contains(keys(aws_route_table.main), subnet.vpc_name )  # && since RTB is keyed by vpc.name, we use keys() function to get all VPCs that have RTB 
   }
  subnet_id = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.value.vpc_name].id   # we do this because , route table resource is 'Keyed' to `var.vpc` and in turn, `vpc.name`
}


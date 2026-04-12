locals {

  flat_subnets = flatten([for vpc in var.vpc : [
    for subnet in vpc.subnets : {
      name          = subnet.name
      cidr_block    = subnet.cidr_block
      vpc_name      = vpc.name
      vpc_id        = aws_vpc.main[vpc.name].id
      public_subnet = subnet.public_subnet
      tier          = subnet.tier
    }
    ]
  ])

  # Only VPCs that attach NAT and name a subnet
  nat_by_vpc = {
    for vpc in var.vpc : vpc.name => vpc
    if lookup(vpc, "attach_nat_gateway", false) && lookup(vpc, "nat_subnet_name", null) != null
  }

}

resource "aws_vpc" "main" {
  for_each         = { for vpc in var.vpc : vpc.name => vpc }
  cidr_block       = each.value.cidr_block
  instance_tenancy = "default"

  tags = {
    Name       = each.key
    Managed-By = "terraform"
    Env        = "release"
  }
}

resource "aws_subnet" "main" {
  for_each   = { for subnet in local.flat_subnets : subnet.name => subnet }
  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block

  tags = {
    Name          = each.key
    Managed-By    = "terraform"
    Env           = "release"
    public_subnet = each.value.public_subnet
    tier          = each.value.tier
  }
}

# ---------- INTERNET GATEWAY RESOURCE ----------
resource "aws_internet_gateway" "main" {
  for_each = { for vpc in var.vpc : vpc.name => vpc
    if lookup(vpc, "attach_internet_gateway", null)
  }
  vpc_id = aws_vpc.main[each.key].id
}

# ---------- ELASTIC IP RESOURCE FOR NAT GATEWAY----------
resource "aws_eip" "nat" {
  for_each = local.nat_by_vpc
  domain = "vpc"
  tags = {
    Name       = "${each.key}-nat-eip"
    Managed-By = "terraform"
    Env        = "release"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# ---------- NAT GATEWAY RESOURCE ----------
resource "aws_nat_gateway" "main" {
  for_each = local.nat_by_vpc
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main[each.value.nat_subnet_name].id

  tags = {
    Name = "${each.key}-nat-gateway"
    Managed-By = "terraform"
    Env        = "release"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


# ---------- PUBLIC ROUTE TABLE RESOURCE ----------
resource "aws_route_table" "public_main" {
  for_each = { for vpc in var.vpc : vpc.name => vpc
    if lookup(vpc, "attach_route_table", null)
  }
  vpc_id = aws_vpc.main[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[each.key].id  # Route to Internet
  }
}

# ---------- PRIVATE ROUTE TABLE RESOURCE ----------
resource "aws_route_table" "private_main" {
  for_each = { for vpc in var.vpc : vpc.name => vpc
    if lookup(vpc, "attach_route_table", null)
  }
  vpc_id = aws_vpc.main[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id # Route to NAT Gateway
  }
}

### In the below resource , please notice that the route table resource above is keyed using vpc.name 
### So we have to have vpc name in our flat subnets struct
### Then with the flat subnets struct, we check if public subnet == true AND keys of RTB resource above(which is vpc.name) - basically checking which VPCs have RTBs
### in the last line of the resource below, we have to get the RTB IDs via. vpc.name , because of all above stated reasons.

# ---------- PUBLIC ROUTE TABLE ASSOCIATION RESOURCE ----------
resource "aws_route_table_association" "public_main" {
  for_each = { for subnet in local.flat_subnets : subnet.name => subnet
    if subnet.public_subnet == true && contains(keys(aws_route_table.public_main), subnet.vpc_name) # && since RTB is keyed by vpc.name, we use keys() function to get all VPCs that have RTB 
  }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public_main[each.value.vpc_name].id # we do this because , route table resource is 'Keyed' to `var.vpc` and in turn, `vpc.name`
}

# ---------- PRIVATE ROUTE TABLE ASSOCIATION RESOURCE ----------
resource "aws_route_table_association" "private_main" {
  for_each = { for subnet in local.flat_subnets : subnet.name => subnet
    if subnet.public_subnet == false && contains(keys(aws_route_table.private_main), subnet.vpc_name) # && since RTB is keyed by vpc.name, we use keys() function to get all VPCs that have RTB 
  }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private_main[each.value.vpc_name].id # we do this because , route table resource is 'Keyed' to `var.vpc` and in turn, `vpc.name`
}
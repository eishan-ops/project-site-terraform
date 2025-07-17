# ######
# # security groups 

locals {
  flat_security_groups = flatten([for vpc in var.vpc : [
    for security_group_name in vpc.security_groups : {
      vpc_name            = vpc.name
      security_group_name = security_group_name
    }
    ]
  ])

  flat_security_groups_rules = flatten([for sg_name, rules in var.security_group_rules : [
    for rule in rules : merge(rule, { sg_name = sg_name }) # merge function takes a set of maps or list and merges them. We do this to associate each rule with the SG name.
  ]])

  #  so after merge , the structure looks as such : 
  #  {
  #   name        = "home-to-fastapi"
  #   cidr_ipv4   = "x.x.x.x"
  #   ip_protocol = "tcp"
  #   from_port = 8000
  #   to_port     = 8000
  #   sg_name     = "xyz"
  #  }

  security_group_rule_map = { for rule in local.flat_security_groups_rules :
    "${rule.name}-${rule.to_port}-${rule.sg_name}" => rule
  }

  # we need to make a map to have a unique object ,
  # we need this unique object - to lop over the ingress rule resource 
  # for_each = { for rule in local.flat_security_group_rules : 
  #                   "${rule.name}-${rule.to_port}-${rule.sg_name}" => rule     
  #             }
}


resource "aws_security_group" "main" {
  for_each    = { for security_group in local.flat_security_groups : security_group.security_group_name => security_group }
  name        = each.key
  description = "something -something"
  vpc_id      = aws_vpc.main[each.value.vpc_name].id

  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each          = local.security_group_rule_map
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  security_group_id = aws_security_group.main[each.value.sg_name].id
}
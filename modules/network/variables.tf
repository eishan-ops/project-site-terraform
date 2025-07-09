variable "vpc" {
    type = list(object({
        name = string
        cidr_block = string
        attach_internet_gateway = bool
        attach_route_table = bool
        security_groups = list(string)
        subnets = list(object({
            name = string
            cidr_block = string
            public_subnet = bool
            tier = string
        }))
    }))
}

variable "security_group_rules" {
  type = map(list(object({
    name = string
    cidr_ipv4 = string
    ip_protocol = string
    from_port = number
    to_port = number
  })))
}
variable "vpc" {
  type = list(object({
    name                    = string
    cidr_block              = string
    attach_internet_gateway = bool
    attach_route_table      = bool
    security_groups         = list(string)
    subnets = list(object({
      name          = string
      cidr_block    = string
      public_subnet = bool
      tier          = string
    }))
  }))
}

variable "subnets" {
  type = list(object({
    name          = string
    cidr_block    = string
    vpc_name      = string
    vpc_id        = string
    public_subnet = bool
    tier          = string
  }))
}

variable "vms" {
  type = list(object({
    name              = string
    vpc_name          = string
    subnet_id         = string
    security_group_id = string
    tier              = string
  }))
}
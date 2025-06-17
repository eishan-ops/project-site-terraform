variable "vpc" {
    type = list(object({
        name = string
        cidr_block = string
        attach_internet_gateway = bool
        attach_route_table = bool
        subnets = list(object({
            name = string
            cidr_block = string
        }))
    }))
}
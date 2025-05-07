variable "vpc" {
    type = list(object({
        name = string
        cidr_block = string
        subnets = list(object({
            name = string
            cidr_block = string
        }))
    }))
}
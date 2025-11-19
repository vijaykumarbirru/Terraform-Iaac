variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "enable_nat" {
  type    = bool
  default = true
}

variable "enable_igw" {
  type    = bool
  default = true
}

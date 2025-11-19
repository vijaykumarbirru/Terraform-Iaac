variable "name" {
  type = string
}

variable "requester_vpc_id" {
  type = string
}

variable "accepter_vpc_id" {
  type = string
}

variable "requester_private_route_table_id" {
  type = string
}

variable "requester_public_route_table_id" {
  type = string
}

variable "accepter_private_route_table_id" {
  type = string
}

variable "requester_cidr" {
  type = string
}

variable "accepter_cidr" {
  type = string
}

variable "enable_requester_public_route" {
  type    = bool
  default = true
}

variable "auto_accept" {
  type    = bool
  default = true
}

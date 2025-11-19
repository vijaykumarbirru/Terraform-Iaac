variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "endpoint_service_name" {
  description = "Service name from backend VPC, like com.amazonaws.vpce.us-east-1.vpce-svc-xxxx"
  type        = string
}

variable "allowed_cidr" {
  type = string
}

variable "port" {
  type    = number
  default = 80
}
variable "sg_name" {
  type    = string
  default = "endpoint-interface"
}

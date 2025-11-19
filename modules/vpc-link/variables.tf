variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "backend_port" {
  type    = number
  default = 8080
}

variable "backend_ip" {
  type        = string
  description = "Backend EC2 or EKS service ENI IP"
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

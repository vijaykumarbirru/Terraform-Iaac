############################
# PROJECT GLOBAL
############################

variable "project" {
  type = string
}

variable "env" {
  type = string
}
variable "region" {
  type = string
}

############################
# VPC-GATEWAY
############################

variable "vpc_gateway_name" {
  type = string
}

variable "vpc_gateway_cidr" {
  type = string
}

variable "vpc_gateway_public_subnets" {
  type = list(string)
}

variable "vpc_gateway_private_subnets" {
  type = list(string)
}

############################
# VPC-BACKEND
############################

variable "vpc_backend_name" {
  type = string
}

variable "vpc_backend_cidr" {
  type = string
}

# Small public subnet for NAT only in backend VPC
variable "vpc_backend_nat_public_subnet" {
  type = string
}

variable "vpc_backend_private_subnets" {
  type = list(string)
}

############################
# EC2 TEST INSTANCES
############################

variable "gateway_ec2_ami" {
  type = string
}

variable "backend_ec2_ami" {
  type = string
}

variable "gateway_ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "backend_ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_key_name" {
  type = string
}

############################
# EKS CLUSTERS
############################

variable "k8s_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

#variable "gateway_instance_ty" {
# description = "Node instance type for gateway EKS"
# type        = string
#  default     = "t3.medium"
#}

# variable "backend_instance_ty" {
#   description = "Node instance type for backend EKS"
#   type        = string
#   default     = "t3.medium"
# }

############################
# ECR
############################

variable "ecr_repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
}


variable "backend_alb_arn" {
  description = "Application Load Balancer ARN (backend ALB)"
  type        = string
}
# variable "nlb_arn" {
#   type = string
  
# }

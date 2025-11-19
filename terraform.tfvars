##########################################
# PROJECT GLOBAL
##########################################
project = "multi-vpc-eks"
env     = "dev"
region  = "us-west-2"

##########################################
# VPC-GATEWAY CONFIG
##########################################
vpc_gateway_name = "vpc-gateway"
vpc_gateway_cidr = "10.10.0.0/16"

vpc_gateway_public_subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24",
]

vpc_gateway_private_subnets = [
  "10.10.11.0/24",
  "10.10.12.0/24",
]

##########################################
# VPC-BACKEND CONFIG
##########################################
vpc_backend_name = "vpc-backend"
vpc_backend_cidr = "10.20.0.0/16"

# Only for NAT
vpc_backend_nat_public_subnet = "10.20.1.0/28"

vpc_backend_private_subnets = [
  "10.20.11.0/24",
  "10.20.12.0/24",
]

##########################################
# EC2 TEST INSTANCES
##########################################

gateway_ec2_ami = "ami-00024168944f97fed"
backend_ec2_ami = "ami-00024168944f97fed"

gateway_ec2_instance_type = "t3.micro"
backend_ec2_instance_type = "t3.micro"

# MUST EXIST in AWS → "my-ssh-key"
ec2_key_name = "my-ssh-key"

##########################################
# EKS CLUSTERS
##########################################

k8s_version = "1.32"

# gateway_instance_ty = "t3.micro"
# backend_instance_ty = "t3.micro"

##########################################
# ECR
##########################################

ecr_repositories = [
  "gateway-api",
  "backend-api",
]


backend_alb_arn = "arn:aws:elasticloadbalancing:us-west-2:721500739616:loadbalancer/app/k8s-app-albingre-3a38bb3501/8099cbfae60fa5c1"
                  
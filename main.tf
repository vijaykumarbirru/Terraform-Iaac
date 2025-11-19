###########################################
# VPC-GATEWAY (public + private)
###########################################
module "vpc_gateway" {
  source = "./modules/vpc-complete"

  vpc_name             = var.vpc_gateway_name
  vpc_cidr             = var.vpc_gateway_cidr
  public_subnets_cidr  = var.vpc_gateway_public_subnets
  private_subnets_cidr = var.vpc_gateway_private_subnets

  enable_nat = true
  enable_igw = true
}

###########################################
# VPC-BACKEND (private only + NAT subnet)
###########################################
module "vpc_backend" {
  source = "./modules/vpc-complete"

  vpc_name             = var.vpc_backend_name
  vpc_cidr             = var.vpc_backend_cidr
  public_subnets_cidr  = [var.vpc_backend_nat_public_subnet]
  private_subnets_cidr = var.vpc_backend_private_subnets

  enable_nat = true
  enable_igw = true
}

###########################################
# VPC PEERING (gateway ↔ backend)
###########################################
module "vpc_peering_gateway_backend" {
  source = "./modules/vpc-peering"

  name = "vpc-gateway-backend"

  requester_vpc_id  = module.vpc_gateway.vpc_id
  accepter_vpc_id   = module.vpc_backend.vpc_id

  requester_private_route_table_id = module.vpc_gateway.private_route_table_id
  requester_public_route_table_id  = module.vpc_gateway.public_route_table_id
  accepter_private_route_table_id  = module.vpc_backend.private_route_table_id

  requester_cidr = var.vpc_gateway_cidr
  accepter_cidr  = var.vpc_backend_cidr

  enable_requester_public_route = true
  auto_accept                   = true
}

###########################################
# EC2 in VPC-GATEWAY (PUBLIC)
###########################################
module "ec2_gateway_public" {
  source = "./modules/ec2"

  name      = "gateway-test-ec2"
  vpc_id    = module.vpc_gateway.vpc_id
  subnet_id = module.vpc_gateway.public_subnet_ids[0]

  public_ip = true
  key_name  = var.ec2_key_name

  ami           = var.gateway_ec2_ami
  instance_type = var.gateway_ec2_instance_type
  user_data = file("${path.module}/user-data/gateway-bootstrap.sh")

  ingress_rules = [
    {
      description = "Allow ALL inbound for testing"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}



###########################################
# EC2 in VPC-BACKEND (PRIVATE)
###########################################
module "ec2_backend_private" {
  source = "./modules/ec2"

  name      = "backend-test-ec2"
  vpc_id    = module.vpc_backend.vpc_id
  subnet_id = module.vpc_backend.private_subnet_ids[0]

  public_ip = false
  key_name  = var.ec2_key_name

  ami           = var.backend_ec2_ami
  instance_type = var.backend_ec2_instance_type
  user_data = file("${path.module}/user-data/backend-bootstrap.sh")
  
  # Only allow SSH from gateway EC2 private IP
  ingress_rules = [
    {
      description = "Allow SSH only from Gateway EC2 private IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${module.ec2_gateway_public.private_ip}/32"]
    }
  ]
}

##########################################
# EKS: Gateway VPC
##########################################
# module "eks_gateway" {
#   source = "./modules/eks"

#   cluster_name       = "eks-gateway"
#   cluster_version    = var.k8s_version
#   private_subnet_ids = module.vpc_gateway.private_subnet_ids
#   vpc_id             = module.vpc_gateway.vpc_id
#   instance_type      = var.gateway_instance_ty
#   peer_cidrs         = [var.vpc_backend_cidr] # Allow backend → gateway API

#   tags = {
#     Project = "eks-project-gateway"
#     Env     =  "dev"
#     Name    = "eks-gateway"
#   }
# }

module "eks_gateway" {
  source = "./modules/eks"

  cluster_name       = "eks-gateway"
  cluster_version    = var.k8s_version
  vpc_id             = module.vpc_gateway.vpc_id
  private_subnet_ids =  module.vpc_gateway.private_subnet_ids
  //public_subnet_ids  = module.network.public_subnet_ids
  region             = var.region

  node_desired_size = 2
  node_min_size     = 1
  node_max_size     = 4
  instance_types    = ["t3.small"]
  disk_size         = 30

  addon_versions = {
    vpc_cni                = "latest"
    kube_proxy             = "latest"
    coredns                = "latest"
    eks_pod_identity_agent = "latest"
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

######################
# EKS Cluster Module Gateway
######################
# module "eks" {
#   source = "../../modules/eks"

#   cluster_name       = "eks-gateway"
#   cluster_version    = "1.32"
#   vpc_id             = module.vpc_gateway.vpc_id
#   private_subnet_ids = module.vpc_gateway.private_subnet_ids
#   public_subnet_ids  = module.vpc_gateway.public_subnet_ids
#   region             = "us-west-2"

#   node_desired_size = 2
#   node_min_size     = 1
#   node_max_size     = 4
#   instance_types    = ["t3.medium"]
#   disk_size         = 30

#   addon_versions = {
#     vpc_cni                = "latest"
#     kube_proxy             = "latest"
#     coredns                = "latest"
#     eks_pod_identity_agent = "latest"
#   }

#   tags = {
#     Project = "eks-project-gateway"
#     Env     = "dev"
#   }
# }
##########################################
# EKS: Backend VPC
##########################################
# module "eks_backend" {
#   source = "./modules/eks"

#   cluster_name       = "eks-backend"
#   cluster_version    = var.k8s_version
#   private_subnet_ids = module.vpc_backend.private_subnet_ids
#   vpc_id             = module.vpc_backend.vpc_id
#   instance_type      = var.backend_instance_ty
#   peer_cidrs         = [var.vpc_gateway_cidr] # Allow gateway → backend API

#   tags = {
#     Project = "eks-project-backend"
#     Env     = "dev"
#   }
# }
module "eks_backend" {
  source = "./modules/eks"

  cluster_name       = "eks-backend"
  cluster_version    = var.k8s_version
  vpc_id             = module.vpc_backend.vpc_id
  private_subnet_ids = module.vpc_backend.private_subnet_ids
  //public_subnet_ids  = module.network.public_subnet_ids
  region             = var.region

  node_desired_size = 2
  node_min_size     = 1
  node_max_size     = 4
  instance_types    = ["t3.small"]
  disk_size         = 30

  addon_versions = {
    vpc_cni                = "latest"
    kube_proxy             = "latest"
    coredns                = "latest"
    eks_pod_identity_agent = "latest"
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

######################
# EKS Cluster Module Backend
######################
# module "eks" {
#   source = "../../modules/eks"

#   cluster_name       = "eks-backend"
#   cluster_version    = "1.32"
#   vpc_id             = module.vpc_backend.vpc_id
#   private_subnet_ids = module.vpc_backend.private_subnet_ids
#   public_subnet_ids  = module.vpc_backend.public_subnet_ids
#   region             = "us-west-2"

#   node_desired_size = 2
#   node_min_size     = 1
#   node_max_size     = 4
#   instance_types    = ["t3.medium"]
#   disk_size         = 30

#   addon_versions = {
#     vpc_cni                = "latest"
#     kube_proxy             = "latest"
#     coredns                = "latest"
#     eks_pod_identity_agent = "latest"
#   }

#   tags = {
#     Project = "eks-project-backend"
#     Env     = "dev"
#   }
# }
##########################################
# ECR REPOSITORIES
##########################################
module "ecr" {
  source = "./modules/ecr"

  for_each = toset(var.ecr_repositories)

  repository_name = each.value
  scan_on_push    = true
  lifecycle_policy = file("lifecycle.json")

  tags = {
    Project = var.project
    Env     = var.env
    Service = each.value
  }
}
##########################################
# IAM POLICY for ALB controller
##########################################
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for ALB Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller-policy.json")
}

##########################################
# IRSA ROLE FOR GATEWAY EKS CLUSTER
##########################################

# module "alb_irsa_gateway" {
#   source = "./modules/iam-role"

#   name        = "eks-gateway-alb-controller-irsa"
#   description = "IRSA for ALB controller on Gateway cluster"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = "sts:AssumeRoleWithWebIdentity",
#       Principal = {
#         Federated = module.eks_gateway.oidc_provider_arn
#       },
#       Condition = {
#         "StringEquals" = {
#           "${replace(module.eks_gateway.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })

#   policy_arns = [
#     aws_iam_policy.aws_load_balancer_controller.arn
#   ]

#   tags = {
#     Env = var.env
#     Project = var.project
#     Cluster = "gateway"
#   }
# }

##########################################
# IRSA ROLE FOR BACKEND EKS CLUSTERR
##########################################

# module "alb_irsa_backend" {
#   source = "./modules/iam-role"

#   name        = "eks-backend-alb-controller-irsa"
#   description = "IRSA for ALB controller on Backend cluster"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = "sts:AssumeRoleWithWebIdentity",
#       Principal = {
#         Federated = module.eks_backend.oidc_provider_arn
#       },
#       Condition = {
#         "StringEquals" = {
#           "${replace(module.eks_backend.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })

#   policy_arns = [
#     aws_iam_policy.aws_load_balancer_controller.arn
#   ]

#   tags = {
#     Env = var.env
#     Project = var.project
#     Cluster = "backend"
#   }
# }
##########################################
# vpc-link
##########################################

# module "vpc_link_backend" {
#   source = "./modules/vpc-link"

#   name        = "backend-app"
#   vpc_id      = module.vpc_backend.vpc_id
#   subnet_ids  = module.vpc_backend.private_subnet_ids
#   backend_ip  = module.ec2_backend_private.private_ip
#   backend_port = 8080
# }


############################################
# MODULE: NLB → ALB
############################################

module "nlb_to_alb" {
  source = "./modules/nlb_to_alb"
  name       = "nlb-routing-to-backend"
  vpc_id     = module.vpc_backend.vpc_id
  private_subnet_ids = module.vpc_backend.private_subnet_ids
  alb_arn    = var.backend_alb_arn
}


# MODULE: NLB → ALB
module "proxy_vpce_service" {
  source = "./modules/vpce_service"

  name    = "proxy-application-routing"
  nlb_arn = module.nlb_to_alb.nlb_arn   

  allowed_principals = [
    "arn:aws:iam::721500739616:root"     
   
  ]
}

module "gateway_endpoint" {
  source = "./modules/vpc-endpoint-interface"
  name                  = "proxy-application-routing"
  vpc_id                = module.vpc_gateway.vpc_id
  subnet_ids            = module.vpc_gateway.private_subnet_ids
  endpoint_service_name = module.proxy_vpce_service.service_name
  allowed_cidr = "10.0.0.0/8"
  port         = 80
  sg_name = "endpoint-interface"
}
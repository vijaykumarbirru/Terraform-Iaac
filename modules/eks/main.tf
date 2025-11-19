terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
}


data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  create_iam_role = false
  iam_role_arn = "arn:aws:iam::721500739616:role/eks-gateway-eks-cluster-role"
   # ❗ KMS + Encryption DISABLED
  create_kms_key            = false
  # encrypt_api_server        = false
  cluster_encryption_config = {}

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types
      disk_size      = var.disk_size
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      labels         = { role = "workers" }
      taints         = []
      update_config  = { max_unavailable = 1 }
      create_iam_role = false
      iam_role_arn  = "arn:aws:iam::721500739616:role/eks-gateway-eks-node-role"
      # create_kms_key = false
    }
  }

  enable_irsa = false

  # Core EKS add-ons
  cluster_addons = {
    vpc-cni = {
      most_recent = var.addon_versions.vpc_cni == "latest"
      addon_version = var.addon_versions.vpc_cni == "latest" ? null : var.addon_versions.vpc_cni
    }
    kube-proxy = {
      most_recent = var.addon_versions.kube_proxy == "latest"
      addon_version = var.addon_versions.kube_proxy == "latest" ? null : var.addon_versions.kube_proxy
    }
    coredns = {
      most_recent = var.addon_versions.coredns == "latest"
      addon_version = var.addon_versions.coredns == "latest" ? null : var.addon_versions.coredns
    }
    eks-pod-identity-agent = {
      most_recent = var.addon_versions.eks_pod_identity_agent == "latest"
      addon_version = var.addon_versions.eks_pod_identity_agent == "latest" ? null : var.addon_versions.eks_pod_identity_agent
    }
  }

  tags = var.tags
}

###########################################
# IRSA - OPENID CONNECT PROVIDER
###########################################

# Get TLS certificate from the EKS OIDC issuer
# data "tls_certificate" "oidc" {
#   url = module.eks.identity[0].oidc[0].issuer
# }

# # Create OIDC Provider for IRSA
# resource "aws_iam_openid_connect_provider" "eks_oidc" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
#   url             = module.eks.identity[0].oidc[0].issuer

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.cluster_name}-oidc-provider"
#     }
#   )
# }

output "cluster_name"        { value = module.eks.cluster_name }
output "cluster_endpoint"    { value = module.eks.cluster_endpoint }
output "cluster_ca"          { value = module.eks.cluster_certificate_authority_data }
output "oidc_provider_arn"   { value = module.eks.oidc_provider_arn }
output "node_group_role_arn" { value = module.eks.eks_managed_node_groups["default"].iam_role_arn }

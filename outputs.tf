#########################################
# VPC-GATEWAY OUTPUTS
#########################################

output "vpc_gateway_id" {
  description = "VPC ID for vpc-gateway"
  value       = module.vpc_gateway.vpc_id
}

output "vpc_gateway_public_subnets" {
  description = "Public subnet IDs for vpc-gateway"
  value       = module.vpc_gateway.public_subnet_ids
}

output "vpc_gateway_private_subnets" {
  description = "Private subnet IDs for vpc-gateway"
  value       = module.vpc_gateway.private_subnet_ids
}

output "vpc_gateway_public_route_table_id" {
  description = "Public route table ID for vpc-gateway"
  value       = module.vpc_gateway.public_route_table_id
}

output "vpc_gateway_private_route_table_id" {
  description = "Private route table ID for vpc-gateway"
  value       = module.vpc_gateway.private_route_table_id
}

#########################################
# VPC-BACKEND OUTPUTS
#########################################

output "vpc_backend_id" {
  description = "VPC ID for vpc-backend"
  value       = module.vpc_backend.vpc_id
}

output "vpc_backend_public_subnets" {
  description = "Public NAT subnet ID for vpc-backend"
  value       = module.vpc_backend.public_subnet_ids
}

output "vpc_backend_private_subnets" {
  description = "Private subnet IDs for vpc-backend"
  value       = module.vpc_backend.private_subnet_ids
}

output "vpc_backend_private_route_table_id" {
  description = "Private route table ID for vpc-backend"
  value       = module.vpc_backend.private_route_table_id
}

#########################################
# VPC PEERING OUTPUTS
#########################################

output "vpc_peering_connection_id" {
  description = "VPC Peering connection ID between vpc-gateway and vpc-backend"
  value       = module.vpc_peering_gateway_backend.vpc_peering_id
}

#########################################
# EC2 GATEWAY (PUBLIC EC2)
#########################################

output "gateway_public_ec2_public_ip" {
  description = "Public IP of the gateway EC2 instance"
  value       = module.ec2_gateway_public.public_ip
}

output "gateway_public_ec2_private_ip" {
  description = "Private IP of the gateway EC2 instance"
  value       = module.ec2_gateway_public.private_ip
}

#########################################
# EC2 BACKEND (PRIVATE EC2)
#########################################

output "backend_private_ec2_private_ip" {
  description = "Private IP of backend private EC2 instance"
  value       = module.ec2_backend_private.private_ip
}



#########################################
# ECR
#########################################

output "ecr_repository_urls" {
  description = "Map of ECR repo name -> URL"
  value       = { for name, m in module.ecr : name => m.repository_url }
}


# # 
# # IRSA 
# # 
# output "eks_gateway_oidc_arn" {
#   value = module.eks_gateway.oidc_provider_arn
# }

# output "eks_gateway_oidc_url" {
#   value = module.eks_backend.identity[0].oidc[0].issuer
# }

# output "eks_backend_oidc_arn" {
#   value = module.eks_backend.oidc_provider_arn
# }

# output "eks_backend_oidc_url" {
#   value = module.eks_backend.identity[0].oidc[0].issuer
# }
############################################
# OUTPUTS
############################################

output "nlb_dns_name" {
  value = module.nlb_to_alb.nlb_dns
}

output "nlb_arn" {
  value = module.nlb_to_alb.nlb_arn
}

output "nlb_security_group" {
  value = module.nlb_to_alb.nlb_sg_id
}

output "backend_endpoint_service_name" {
  description = "Name of the AWS VPC Endpoint Service created from Backend NLB"
  value       = module.proxy_vpce_service.service_name
}


########################################
# INTERFACE ENDPOINT (Gateway VPC)
########################################

output "gateway_endpoint_id" {
  description = "The ID of the interface VPC Endpoint in the Gateway VPC"
  value       = module.gateway_endpoint.vpc_endpoint_id
}

output "gateway_endpoint_dns_names" {
  description = "DNS names assigned to the interface endpoint"
  value       = module.gateway_endpoint.dns_entries
}

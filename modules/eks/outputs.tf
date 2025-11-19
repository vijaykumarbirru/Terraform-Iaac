output "kubeconfig" {
  value = {
    name     = module.eks.cluster_name
    endpoint = module.eks.cluster_endpoint
    ca       = module.eks.cluster_certificate_authority_data
  }
}

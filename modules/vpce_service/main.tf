###############################################
# VPC ENDPOINT SERVICE (PrivateLink Provider)
###############################################

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = true
  network_load_balancer_arns = [var.nlb_arn]

  allowed_principals = var.allowed_principals

  tags = {
    Name = var.name
  }
}

###############################################
# OPTIONAL: ALLOW CONSUMER VPC TO CONNECT
###############################################

resource "aws_vpc_endpoint_service_allowed_principal" "principals" {
  count                        = length(var.allowed_principals)
  vpc_endpoint_service_id      = aws_vpc_endpoint_service.this.id
  principal_arn                = var.allowed_principals[count.index]
}

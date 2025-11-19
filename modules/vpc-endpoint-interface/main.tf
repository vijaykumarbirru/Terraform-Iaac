###############################################
# SECURITY GROUP for VPC Endpoint
###############################################

resource "aws_security_group" "endpoint_sg" {
  name        = var.sg_name
  description = "SG for Interface VPC Endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic from VPC internal CIDR"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

###############################################
# INTERFACE VPC ENDPOINT
###############################################

resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = var.endpoint_service_name
  vpc_endpoint_type = "Interface"

  subnet_ids = var.subnet_ids

  private_dns_enabled = false

  security_group_ids = [
    aws_security_group.endpoint_sg.id,
  ]

  tags = {
    Name = var.name
  }
}

###############################################
# OUTPUTS
###############################################

output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "vpc_endpoint_dns" {
  value = aws_vpc_endpoint.this.dns_entry
}

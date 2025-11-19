output "service_id" {
  value = aws_vpc_endpoint_service.this.id
}

output "service_name" {
  value = aws_vpc_endpoint_service.this.service_name
}

output "dns_name" {
  value = aws_vpc_endpoint_service.this.service_name
}

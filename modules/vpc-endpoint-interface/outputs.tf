output "endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "dns_entries" {
  value = aws_vpc_endpoint.this.dns_entry
}

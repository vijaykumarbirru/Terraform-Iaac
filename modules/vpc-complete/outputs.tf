output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  value = length(aws_nat_gateway.nat) > 0 ? aws_nat_gateway.nat[0].id : null
}

output "igw_id" {
  value = length(aws_internet_gateway.igw) > 0 ? aws_internet_gateway.igw[0].id : null
}

output "private_route_table_id" {
  value = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

output "public_route_table_id" {
  value = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

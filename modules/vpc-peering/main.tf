resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  auto_accept = var.auto_accept

  tags = {
    Name = var.name
  }
}

############################################
# Requester → Accepter (Private RT)
############################################

resource "aws_route" "requester_private_to_accepter" {
  route_table_id            = var.requester_private_route_table_id
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

############################################
# Requester → Accepter (Public RT)
############################################

resource "aws_route" "requester_public_to_accepter" {
  count = var.enable_requester_public_route ? 1 : 0

  route_table_id            = var.requester_public_route_table_id
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

############################################
# Accepter → Requester (Private RT)
############################################

resource "aws_route" "accepter_private_to_requester" {
  route_table_id            = var.accepter_private_route_table_id
  destination_cidr_block    = var.requester_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

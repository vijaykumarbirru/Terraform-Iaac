output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nlb_dns" {
  value = aws_lb.nlb.dns_name
}

output "nlb_sg_id" {
  value = aws_security_group.nlb_sg.id
}

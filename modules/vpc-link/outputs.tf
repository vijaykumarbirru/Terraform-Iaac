output "api_endpoint" {
  value = aws_apigatewayv2_stage.stage.invoke_url
}

output "nlb_dns" {
  value = aws_lb.nlb.dns_name
}

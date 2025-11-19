###############################################
# PRIVATE NLB (Backend)
###############################################
resource "aws_lb" "nlb" {
  name               = "${var.name}-private-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.name}-nlb"
  }
}

###############################################
# Target Group (Backend Service)
###############################################
resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-tg"
  port        = var.backend_port
  protocol    = var.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    port                = var.backend_port
    protocol            = var.protocol
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Attach Backend IP as target
resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.backend_ip
  port             = var.backend_port
}

###############################################
# NLB Listener
###############################################
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.backend_port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

###############################################
# API Gateway VPC LINK
###############################################
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.name}-vpc-link"
  subnet_ids         = var.subnet_ids
  security_group_ids = []

  tags = {
    Name = "${var.name}-vpc-link"
  }
}

###############################################
# API GATEWAY (HTTP API)
###############################################
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.listener.arn
  connection_type  = "VPC_LINK"
  connection_id    = aws_apigatewayv2_vpc_link.vpc_link.id
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

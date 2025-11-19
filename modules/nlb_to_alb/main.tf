##########################################
# SECURITY GROUP for NLB ENIs
##########################################
resource "aws_security_group" "nlb_sg" {
  name        = "${var.name}-sg"
  description = "SG for internal NLB ENIs"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow VPC traffic"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##########################################
# INTERNAL NLB
##########################################
resource "aws_lb" "nlb" {
  name               = var.name
  load_balancer_type = "network"
  internal           = true
  subnets            = var.private_subnet_ids

  security_groups    = [aws_security_group.nlb_sg.id]

  # tags = {
  #   Name = var.name
  # }
}

##########################################
# TARGET GROUP (ALB target)
##########################################
resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = "80"
  }
}

##########################################
# ATTACH ALB AS NLB TARGET
##########################################
resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.alb_arn
  port             = 80
}

##########################################
# NLB LISTENER
##########################################
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

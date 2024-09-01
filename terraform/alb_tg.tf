data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "es2-vadebicicleta-terraform-states"
    region = "us-east-1"
    key    = "apps/alb.tfstate"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "${local.app_name}-tg"
  port        = local.app_port
  protocol    = "HTTP"
  vpc_id      = "vpc-0cd5ffeef05fb3327"

#   health_check {
#     port = local.app_port
#     path = "/actuator-health"
#     protocol = "HTTP"
#   }

 tags = {
    Name = "${local.app_name}-tg"
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = data.terraform_remote_state.infra.outputs.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = ["/${local.app_name}/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
 target_group_arn = aws_lb_target_group.tg.arn
 target_id        = aws_instance.example_app.id
 port             = local.app_port
}

output "alb_app_dns" { value = "${data.terraform_remote_state.infra.outputs.alb_fqdn}/${local.app_name}" }

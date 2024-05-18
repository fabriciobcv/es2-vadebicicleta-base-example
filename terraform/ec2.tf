data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "example_sg" {
  name = "${local.app_name}-sg"
  description = "Allow all trafic in 8080 port and all outbound traffic"
  tags = {
    Name = "${local.app_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.example_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port = 8080
  to_port = 8080
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.example_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_launch_template" "example_app" {
  name = local.app_name
  image_id = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = local.instace_type

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = templatefile("files/install-and-run-docker.sh.tpl", {
    DOCKER_USERNAME = var.DOCKER_USERNAME
    DOCKER_PASSWORD = var.DOCKER_PASSWORD
  })
}


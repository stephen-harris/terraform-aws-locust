# setup security groups
resource "aws_security_group" "nodes" {
  name        = "locust-nodes"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr
  }

  ingress {
    from_port   = 5557
    to_port     = 5558
    protocol    = "tcp"
    self = true
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

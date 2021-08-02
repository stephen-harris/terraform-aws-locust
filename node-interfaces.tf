resource "aws_network_interface" "master_public_network_interface" {
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.nodes.id]
}

resource "aws_network_interface" "worker_public_network_interface" {
  count           = var.number_of_workers
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.nodes.id]
}

resource "aws_network_interface" "master_private_network_interface" {
  count           = var.use_private_ip ? 1 : 0
  subnet_id       = var.private_subnet_id
  security_groups = [aws_security_group.nodes.id]
}

resource "aws_network_interface" "worker_private_network_interface" {
  count           = var.use_private_ip ? var.number_of_workers : 0
  subnet_id       = var.private_subnet_id
  security_groups = [aws_security_group.nodes.id]
}

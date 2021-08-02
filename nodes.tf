resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-${timestamp()}-key"
  public_key = tls_private_key.temp.public_key_openssh
  lifecycle {
    ignore_changes = [
      key_name,
    ]
  }
}

resource "tls_private_key" "temp" {
  algorithm = "RSA"
}

resource "aws_instance" "master" {
  ami           = var.node_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name


  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.master_public_network_interface.id
  }

  dynamic "network_interface" {
    for_each = var.use_private_ip ? [1] : []
    content {
      device_index         = 1
      network_interface_id = aws_network_interface.master_private_network_interface[0].id
    }
  }

  tags = {
    Name = "${var.name}-master"
  }

  depends_on = [
    aws_security_group.nodes
  ]

  provisioner "file" {
    source      = "${path.module}/supervisord.conf"
    destination = "supervisord.conf"
  }

  provisioner "file" {
    source      = "${var.scripts_folder}/"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = var.use_private_ip ? concat(local.configure_private_network, local.install_locust_master) : local.install_locust_master
  }

  connection {
    host        = var.use_private_ip ? self.private_ip : self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}

resource "aws_instance" "worker" {
  count         = var.number_of_workers
  ami           = var.node_ami
  instance_type = var.worker_instance_type
  key_name      = aws_key_pair.deployer.key_name


  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.slave_public_network_interface[count.index].id
  }


  dynamic "network_interface" {
    for_each = var.use_private_ip ? [1] : []
    content {
      device_index         = 1
      network_interface_id = aws_network_interface.slave_private_network_interface[count.index].id
    }
  }

  tags = {
    Name = "${var.name}-worker"
  }

  depends_on = [
    aws_security_group.nodes
  ]

  provisioner "file" {
    source      = "${path.module}/supervisord.conf"
    destination = "supervisord.conf"
  }

  provisioner "file" {
    source      = "${var.scripts_folder}/"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = var.use_private_ip ? concat(local.configure_private_network, local.install_locust_slave) : local.install_locust_slave
  }

  connection {
    host        = var.use_private_ip ? self.private_ip : self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}

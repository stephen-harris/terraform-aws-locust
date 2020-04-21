
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
  ami                    = var.node_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]
  subnet_id              = var.subnet_id

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
    inline = [
      "echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --master\" >> supervisord.conf",
      "sudo mv supervisord.conf /etc/supervisord.conf",
      "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip",
      "sudo python3 -m pip install --upgrade pip",
      "sudo python3 -m pip install locust && sudo python3 -m pip install pyzmq",
      "wget https://pypi.python.org/packages/80/37/964c0d53cbd328796b1aeb7abea4c0f7b0e8c7197ea9b0b9967b7d004def/supervisor-3.3.1.tar.gz && tar -xvf supervisor*.gz && cd supervisor* && sudo python setup.py install && sudo pip install supervisor",
      "sudo /usr/local/bin/supervisord",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}

resource "aws_instance" "worker" {
  count                  = var.number_of_workers
  ami                    = var.node_ami
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.nodes.id]
  subnet_id              = var.subnet_id

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
    inline = [
      "echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --slave --master-host=${aws_instance.master.private_ip}\" >> supervisord.conf",
      "sudo mv supervisord.conf /etc/supervisord.conf",
      "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip",
      "sudo python3 -m pip install --upgrade pip",
      "sudo python36 -m pip install locust && sudo python36 -m pip install pyzmq",
      "wget https://pypi.python.org/packages/80/37/964c0d53cbd328796b1aeb7abea4c0f7b0e8c7197ea9b0b9967b7d004def/supervisor-3.3.1.tar.gz && tar -xvf supervisor*.gz && cd supervisor* && sudo python setup.py install && sudo pip install supervisor",
      "sudo /usr/local/bin/supervisord",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}
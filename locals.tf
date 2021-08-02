locals {
  configure_private_network = [
    "sudo ip route add 10.0.0.0/8 via ${var.nat_default_gw} dev eth0", //todo: make DEFAULT_GW configurable
    "sudo ip route delete default via ${var.nat_default_gw} dev eth0",
  ]
  install_locust_master = ["echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --master\" >> supervisord.conf",
    "sudo mv supervisord.conf /etc/supervisord.conf",
    "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip",
    "sudo python3 -m pip install --upgrade pip",
    "sudo python3 -m pip install locust && sudo python3 -m pip install pyzmq",
    "wget https://pypi.python.org/packages/80/37/964c0d53cbd328796b1aeb7abea4c0f7b0e8c7197ea9b0b9967b7d004def/supervisor-3.3.1.tar.gz && tar -xvf supervisor*.gz && cd supervisor* && sudo python setup.py install && sudo pip install supervisor",
    "sudo /usr/local/bin/supervisord"
  ]
  install_locust_slave = [
    "echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --slave --master-host=${aws_instance.master.private_ip}\" >> supervisord.conf",
    "sudo mv supervisord.conf /etc/supervisord.conf",
    "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip",
    "sudo python3 -m pip install --upgrade pip",
    "sudo python36 -m pip install locust && sudo python36 -m pip install pyzmq",
    "wget https://pypi.python.org/packages/80/37/964c0d53cbd328796b1aeb7abea4c0f7b0e8c7197ea9b0b9967b7d004def/supervisor-3.3.1.tar.gz && tar -xvf supervisor*.gz && cd supervisor* && sudo python setup.py install && sudo pip install supervisor",
    "sudo /usr/local/bin/supervisord",
  ]
}

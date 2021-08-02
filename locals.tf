locals {
  configure_private_network = [
    "sudo ip route add 10.0.0.0/8 via ${var.nat_default_gw} dev eth0", //todo: make DEFAULT_GW configurable
    "sudo ip route delete default via ${var.nat_default_gw} dev eth0",
  ]
  install_locust_master = ["echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --master\" >> supervisord.conf",
    "sudo mv supervisord.conf /etc/supervisord.conf",
    "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip python-meld3",
    "sudo python3 -m pip install --upgrade pip",
    "sudo python3 -m pip install locust && sudo python3 -m pip install pyzmq supervisor",
    "sudo /usr/local/bin/supervisord"
  ]
  install_locust_slave = [
    "echo \"command=/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=${var.host} --slave --master-host=${aws_instance.master.private_ip}\" >> supervisord.conf",
    "sudo mv supervisord.conf /etc/supervisord.conf",
    "sudo yum -y install gcc python36 python36-virtualenv python36-dev python36-pip python-meld3",
    "sudo python3 -m pip install --upgrade pip",
    "sudo python36 -m pip install locust && sudo python36 -m pip install pyzmq supervisor",
    "sudo /usr/local/bin/supervisord",
  ]
}

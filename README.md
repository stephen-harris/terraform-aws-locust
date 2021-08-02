# AWS Locust terraform module

A terraform module that will create a master & worker nodes, install Locust and run the Locust dashboard

## Usage

### Public subnet
```
module "locust" {
  source = "github.com/stephen-harris/terraform-aws-locust"
  name    = "locust-demo-"
  node_ami = "ami-00890f614e48ce866"
  vpc_id  = "vpc-5678abcd"
  public_subnet_id = "subnet-1234abcde"
  worker_instance_type = "t2.micro"
  host = "https://yoursite.com"
  number_of_workers = 2
  scripts_folder = "./path/to/locust/scripts"
  ingress_cidr = ["0.0.0.0/0"]
}
```

## Private + Public subnet
```
module "locust" {
  source = "github.com/stephen-harris/terraform-aws-locust"
  name    = "locust-demo-"
  node_ami = "ami-00890f614e48ce866"
  vpc_id  = "vpc-5678abcd"
  public_subnet_id = "subnet-1234abcde"
  worker_instance_type = "t2.micro"
  host = "https://yoursite.com"
  number_of_workers = 2
  scripts_folder = "./path/to/locust/scripts"
  ingress_cidr = ["0.0.0.0/0"]
  use_private_ip       = true
  private_subnet_id    = "subnet-0e9f15b887290cbdc"
  nat_default_gw       = "12.34.56.78"
}
```

You can access the URL of the dasbhoard, as well as IPs and private key for the nodes in the outputs

## Argument Reference

The following arguments are supported:

- ``name`` - (Optional) An identifier for locst infrastructure, used to tag and name resources.
- ``host`` - (Required) The target you are load testing
- ``scripts_folder`` - (Required) Path to locust scripts. Must contain locustfile.py.
- ``vpc_id`` - (Required) The VPC ID the nodes will be created.
- ``public_subnet_id`` - (Required) The public subnet ID where the nodes will be created.
- ``node_ami`` - The image ID used for worker instances
- ``worker_instance_type`` - (Optional) EC2 type for the worker instances. Defaults "t2.micro"
- ``number_of_workers`` - (Optional) Number of worker instances used. Defaults 1
- ``ingress_cidr`` - (Optional) List of IPs that can access your dashboard. Deafults ["0.0.0.0/0"].
- ``use_private_ip`` - (Optional)
- ``private_subnet_id`` - (Required if use_private_ip)
- ``nat_default_gw`` - (Required if use_private_ip)

## Attribute Reference

The following attributes are exported:

- ``locust_dashboard`` - URL to the dashboard.
- ``private_key`` - The private key to access the nodes.
- ``master_id`` - The IP of the master node
- ``worker_ips`` - The IP of the worker nodes

## Demo

```
provider "aws" {
  region = "eu-west-1"
  profile = "test"
}

module "networking" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "locust-demo"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-1a"]
  public_subnets     = ["10.0.101.0/24"]
  enable_dns_support = true
}

module "locust" {
  source = "../"
  name    = "locust-demo-"
  node_ami = "ami-00890f614e48ce866"
  vpc_id  = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnets[0]
  worker_instance_type = "t2.micro"
  host = "https://example.com"
  number_of_workers = 2
  scripts_folder = "./scripts"
  ingress_cidr = ["0.0.0.0/0"]
}

output "locust_dashboard" {
  value = module.locust.locust_dashboard
}

output "private_key" {
  value = module.locust.private_key
}

output "master_ip" {
  value = module.locust.master_ip
}

output "worker_ips" {
  value = module.locust.worker_ips
}
```

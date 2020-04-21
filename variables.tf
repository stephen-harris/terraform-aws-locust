variable "name" {
  type    = string
  default = "locust-node"
  description = "Name used to tag nodes and key pair"
}

variable "vpc_id" {
  type    = string
  description = "VPC node cluster lives in"
}

variable "subnet_id" {
  type    = string
  description = "Subnet node cluster lives in"
}

variable "ingress_cidr" {
  type    = list
  default = ["0.0.0.0/0"]
  description = "Which IPs are allowed to access your locust nodes"
}

variable "node_ami" {
  type    = string
  default = "ami-00890f614e48ce866"//TODO Change based on region
}

variable "worker_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "number_of_workers" {
  type    = number
  default = 1
}

variable "host" {
  type    = string
}

variable "scripts_folder" {
  type = string
  description = "Path to folder containing locustfile.py"
}
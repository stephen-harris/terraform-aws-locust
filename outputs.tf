output "locust_dashboard" {
  value = "http://${var.use_private_ip ? aws_instance.master.private_ip : aws_instance.master.public_ip}:8089"
}

output "private_key" {
  value = tls_private_key.temp.private_key_pem
}

output "master_ip" {
  value = var.use_private_ip ? aws_instance.master.private_ip : aws_instance.master.public_ip
}

output "worker_ips" {
  value = var.use_private_ip ? aws_instance.worker.*.private_ip : aws_instance.worker.*.public_ip
}

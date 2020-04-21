output "locust_dashboard" {
  value = "http://${aws_instance.master.public_ip}:8089"
}

output "private_key" {
  value = tls_private_key.temp.private_key_pem
}

output "master_ip" {
  value = aws_instance.master.public_ip
}

output "worker_ips" {
  value = aws_instance.worker.*.public_ip
}

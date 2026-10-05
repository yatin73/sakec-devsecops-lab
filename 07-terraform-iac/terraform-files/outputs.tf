output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.lab_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.lab_instance.public_dns
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.lab_instance.public_ip}"
}

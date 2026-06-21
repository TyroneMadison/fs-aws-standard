output "instance_id" {
  value = aws_instance.this.id
}

output "name" {
  value = local.name
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

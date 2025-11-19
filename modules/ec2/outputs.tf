output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "sg_id" {
  value = aws_security_group.this.id
}

output "instance_id" {
  value = aws_instance.this.id
}

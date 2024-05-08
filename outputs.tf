output "security_group_id" {
  value = aws_security_group.security_group.id
}
output "db_instance_id" {
  value = aws_db_instance.db_instance.id
}
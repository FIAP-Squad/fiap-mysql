output "security_group_id" {
  value = aws_security_group.security_group.id
}
output "db_instance_id" {
  value = aws_db_instance.db_instance.id
}
output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
  description = "The endpoint of the RDS instance"
}
output "rds_address" {
  value = aws_db_instance.db_instance.address
  description = "The address of the RDS instance"
}
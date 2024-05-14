resource "aws_security_group" "security_group" {
  name        = "fiap-rds-api-sg"
  description = "Allow MySQL inbound traffic"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_db_instance" "db_instance" {
    engine = "mysql"
    identifier = "fiap-rds-api-db"
    allocated_storage = 5
    engine_version = "5.7"
    instance_class = "db.t3.micro"
    username = "${var.db_user}"
    password = "${var.db_password}"
    port = "${var.port}"
    parameter_group_name = "default.mysql5.7"
    vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
    skip_final_snapshot = true
    publicly_accessible = true
}
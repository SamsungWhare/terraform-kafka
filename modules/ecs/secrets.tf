data "aws_secretsmanager_secret" "api_dev_db" {
  name = "api_dev_db_access"
}

data "aws_secretsmanager_secret_version" "api_dev_db" {
  secret_id = "${data.aws_secretsmanager_secret.api_dev_db.id}"
}

data "aws_secretsmanager_secret" "s3" {
  name = "s3_user_secret_access_key"
}

data "aws_secretsmanager_secret_version" "s3" {
  secret_id = "${data.aws_secretsmanager_secret.s3.id}"
}

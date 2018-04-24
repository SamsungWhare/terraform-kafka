/*
 * Kafka data
 */

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_role" "ecs_ingest" {
  name = "ecs_ingest"
}

data "aws_vpc" "current" {}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.current.id}"
  filter {
    name   = "tag:terraform"
    values = ["default"]
  }
}

/*
 * Kafka data
 */

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_vpc" "current" {}

data "aws_subnet_ids" "available" {
  vpc_id = "${data.aws_vpc.current.id}"  //  vpc-638be51b
}

data "aws_subnet" "subnet" {
  # count = "${length(data.aws_subnet_ids.available.ids)}"
  id    = "${data.aws_subnet_ids.available.ids[0]}"
}

data "aws_subnet" "static-subnet" {
  # count = "${length(data.aws_subnet_ids.available.ids)}"
  id    = "${data.aws_subnet_ids.available.ids[0]}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.current.id}"
  filter {
    name   = "tag:terraform"
    values = ["default"]
  }
}

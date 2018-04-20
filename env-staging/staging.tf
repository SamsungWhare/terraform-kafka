provider "aws" {
  region = "us-east-1"
}

variable private_key { "default" = "~/.ssh/id_rsa_fddc59216e07448564ee247e3fa42905" }
variable key_name    { default = "saurabh-throwaway" }
variable bastion_ip  { default = "54.210.22.199" }

variable image_tag   { default = "consumer_groups" }

module "kafka" {
    source = "../modules/kafka"
    
    environment = "${terraform.workspace}"

    num_partitions = 30

    private_key = "${var.private_key}"
    key_name = "${var.key_name}"
    bastion_ip = "${var.bastion_ip}"
}

module "nrc" {
    source = "../modules/nrc"

    environment = "staging"

    nrc_instance_count = 1
    docker_image_tag = "${var.image_tag}"

    // TODO: replace following with list of brokers when NRC is ready to accept it
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}

provider "aws" {
  region = "us-east-1"
}

private_key = "~/.ssh/id_rsa_fddc59216e07448564ee247e3fa42905"
key_name    = "saurabh-throwaway"
bastion_ip  = "54.210.22.199"

module "kafka" {
    source = "../modules/kafka"
    
    environment = "fruit-loops"

    num_partitions = 30

    private_key="${var.private_key}"
    key_name = "${var.key_name}"
    bastion_ip = "${var.bastion_ip}"
}

module "nrc" {
    source = "../modules/nrc"

    environment = "staging"

    nrc_instance_count = 1
    docker_image_tag = "consumer_groups"

    // TODO: replace following with list of brokers when NRC is ready to accept it
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}

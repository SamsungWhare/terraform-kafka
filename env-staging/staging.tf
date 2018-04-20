provider "aws" {
  region = "us-east-1"
}

module "kafka" {
    source = "../modules/kafka"
    
    environment = "fruit-loops"

    # private_key="~/.ssh/id_rsa_fddc59216e07448564ee247e3fa42905"
    # key_name = "saurabh-throwaway"
    private_key = "~/Downloads/keylimepie.pem"
    key_name = "keylimepie"

    num_partitions = 30

    ///////
    # zookeeper_addr = 50
}

module "nrc" {
    source = "../modules/nrc"

    environment = "staging"

    nrc_instance_count = 1
    docker_image_tag = "consumer_groups"

    // TODO: replace following with list of brokers when NRC is ready to accept it
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}

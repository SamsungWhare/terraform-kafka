provider "aws" {
  region = "us-east-1"
}

variable "private_key" {
    type        = "string"
    default     = "~/.ssh/id_rsa_fddc59216e07448564ee247e3fa42905" 
}

variable "key_name"    {
    type        = "string"
    default     = "saurabh-throwaway" 
}
variable "bastion_ip"  {
    type        = "string"
    default     = "54.210.22.199" 
}

variable "image_tag"   {
    type        = "string"
    default     = "latest"
}

variable "environment" {
    type        = "string"
    default     = "funk"
}

module "kafka" {
    source = "../modules/kafka"
    
    # environment = "${terraform.workspace}"
    environment = "${var.environment}"

    num_partitions = 30

    private_key = "${var.private_key}"
    key_name = "${var.key_name}"
    bastion_ip = "${var.bastion_ip}"
}

module "ecs" {
    source = "../modules/ecs"

    environment = "staging"

    namespace = "${var.environment}"
    nrc_instance_count = 1
    api_instance_count = 1

    nrc_docker_image_tag = "${var.image_tag}"
    # api_docker_image_tag = "${var.image_tag}" // defaults to `latest`

    // TODO: replace following with list of brokers when NRC is ready to accept it
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}

module "redis" {  
  source = "../modules/redis"

  environment = "${var.environment}"
}

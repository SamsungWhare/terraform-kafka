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
    default     = "consumer_groups"
}

variable "kafka_environment" {
    type        = "string"
    default     = "staging_default"
}

variable "redis_tag_name" {
  type        = "string"
  description = "Tag name for the Redis cluster"
  default     = "stg-redis"
}

variable "redis_tag_environment" {
  type        = "string"
  description = "Tag environment for the Redis cluster"
  default     = "stg-env"
}

# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-elasticache-parameter-group.html
variable "redis_parameter_group_name" {
  type        = "string"
  description = "Parameter Group for ElastiCache"
  default     = "stg-prm-gp"
}

variable "redis_cluster_id" {
  type        = "string"
  description = "Redis cluster identifier"
  default     = "stg-cluster"
}

module "kafka" {
    source = "../modules/kafka"
    
    # environment = "${terraform.workspace}"
    environment = "${var.kafka_environment}"

    num_partitions = 30

    private_key = "${var.private_key}"
    key_name = "${var.key_name}"
    bastion_ip = "${var.bastion_ip}"
}

module "nrc" {
    source = "../modules/nrc"

    environment = "staging"

    nrc_namespace = "${var.kafka_environment}"
    nrc_instance_count = 1

    docker_image_tag = "${var.image_tag}"

    // TODO: replace following with list of brokers when NRC is ready to accept it
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}

module "redis" {
  
  source = "../modules/redis"
  
  redis_cluster_id = "${var.redis_cluster_id}"
  redis_tag_environment = "${var.redis_tag_environment}"
  redis_tag_name = "${var.redis_tag_name}"
  redis_parameter_group_name = "${var.redis_parameter_group_name}"  
}
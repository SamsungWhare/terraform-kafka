/*
 * ECS module variables
 */

variable "api_docker_image_tag" {
  type        = "string"
  description = "looking for code from which git branch"
  default     = "latest"
}

variable "api_instance_count" {
  description = "number of api instances in cluster"
  default     = 1
}

variable "environment" {
  type        = "string"
  description = "prod | staging"
}

variable "kafka_brokers" {
  type        = "string"
  description = "list of kafka brokers exported by the kafka module"
}

variable "namespace" {
  type        = "string"
  description = "usually the git branch"
  default     = "default"
}

variable "nrc_docker_image_tag" {
  type        = "string"
  description = "looking for code from which git branch"
  default     = "latest"
}

variable "nrc_instance_count" {
  description = "number of nrc instances in cluster"
  default     = 1
}

variable "nrc_instance_type" {
  description = "ec2 instance type"
  type        = "string"
  default     = "t2.medium"
}

variable "redis_host" {
  type        = "string"
  description = "Redis host exported by redis module"
}

variable "zk_host" {
  type        = "string"
  description = "Zookeeper host exported by kafka module"
}

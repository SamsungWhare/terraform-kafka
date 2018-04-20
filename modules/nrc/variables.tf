/*
 * NRC module variables
 */

variable "nrc_instance_count" {
  description = "number of nrc instances in cluster"
  default     = 1
}

variable "docker_image_tag" {
  type        = "string"
  description = "looking for code from which git branch"
}

variable "kafka_brokers" {
  type        = "string"
  description = "list of kafka brokers exported by the kafka module"
}

variable "environment" {
  type        = "string"
  description = "prod | staging"
}

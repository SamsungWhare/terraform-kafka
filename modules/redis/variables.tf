variable "redis_tag_name" {
  type        = "string"
  description = "Tag name for the Redis cluster"
}

variable "redis_tag_environment" {
  type        = "string"
  description = "Tag environment for the Redis cluster"
}

# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-elasticache-parameter-group.html
variable "redis_parameter_group_name" {
  type        = "string"
  description = "Parameter Group for ElastiCache"
}

variable "redis_cluster_id" {
  type        = "string"
  description = "Redis cluster identifier"
}

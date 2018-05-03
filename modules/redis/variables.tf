variable "redis_tag_name" {
  type        = "string"
  description = "Tag name for the Redis cluster"
}

variable "redis_tag_environment" {
  type        = "string"
  description = "Tag environment for the Redis cluster"
}

variable "redis_cluster_id" {
  type        = "string"
  description = "Redis cluster identifier"
}

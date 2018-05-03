resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = "1"
  parameter_group_name = "default.redis3.2"
  port                 = "6379"
  subnet_group_name    = "redis-subnet-group"
  security_group_ids   = ["${data.aws_security_group.redis.id}"]
}

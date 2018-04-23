/*
 * Kafka module variables
 */

variable "environment" {
  type        = "string"
  description = "environment to configure"
}

variable "app_name" {
  description = "application name"
  default     = "kafka"
}

variable "availability_zone" {
  type        = "string"
  description = "specific availability zone"
  default     = "us-east-1a"
}

variable "brokers_per_az" {
  description = "number of Kafka brokers per AZ"
  default     = 3
}

variable "zookeeper_ami" {
  type        = "string"
  description = "AWS AMI for zookeeper"
  default     = "ami-1853ac65"
}

variable "zookeeper_user" {
  type        = "string"
  description = "user in zookeeper AMI"
  default     = "ec2-user"
}

variable "zookeeper_instance_type" {
  type        = "string"
  description = "instance type for zookeeper server"
  default     =  "t2.medium"
}

variable "zookeeper_version" {
  description = "Zookeeper version"
  default     = "3.4.10"
}

variable "zookeeper_repo" {
  description = "Zookeeper distro site"
  default     = "http://apache.org/dist/zookeeper"
}

variable "kafka_ami" {
  type        = "string"
  description = "AWS AMI for kafka"
  default     = "ami-1853ac65"
}

variable "kafka_user" {
  type        = "string"
  description = "user in kafka AMI"
  default     = "ec2-user"
}

variable "kafka_instance_type" {
  type        = "string"
  description = "instance type for kafka server"
  default     = "t2.medium"
}

variable "kafka_version" {
  description = "Kafka version"
  default     = "1.1.0"
}

variable "scala_version" {
  description = "Scala version used in Kafka package"
  default     = "2.12"
}

variable "kafka_repo" {
  description = "Kafka distro site"
  default     = "http://apache.org/dist/kafka"
}

variable "ebs_mount_point" {
  description = "mount point for EBS volume"
  default     = "/mnt/kafka"
}

variable "ebs_device_name" {
  description = "EBS attached device"
  default     = "/dev/xvdf"
}

variable "ebs_volume_ids" {
  type        = "list"
  description = "list of EBS volume IDs"
  default     = []
}

variable "num_partitions" {
  description = "number of partitions per topic"
  default     = 3
}

variable "log_retention" {
  description = "retention period (hours)"
  default     = 168
}

variable "subnet_ids" {
  type        = "list"
  description = "list of subnet IDs"
  default     = ["subnet-c19f3bee"]
}

variable "static_subnet_ids" {
  type        = "list"
  description = "list of subnet IDs for static IPs (/24 CIDR)"
  default     = ["subnet-c19f3bee"]
}

variable "security_group_ids" {
  type        = "list"
  description = "list of security group IDs"
  default     = ["sg-8ca35bc5"]
}

variable "iam_instance_profile" {
  type        = "string"
  description = "IAM instance profile"
  default     = "OpsTools"
}

variable "key_name" {
  type        = "string"
  description = "key pair for SSH access"
}

variable "private_key" {
  type        = "string"
  description = "local path to ssh private key"
}

variable "bastion_ip" {
  type        = "string"
  description = "bastion IP address for ssh access"
  default     = "54.210.22.199"
}

variable "bastion_user" {
  type        = "string"
  description = "user on bastion server"
  default     = "ec2-user"
}

variable "cloudwatch_alarm_arn" {
  type        = "string"
  description = "cloudwatch alarm ARN"
  default     = "arn:aws:sns:us-east-1:489114792760:Kafka"
}

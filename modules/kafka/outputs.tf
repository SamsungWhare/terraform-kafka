/*
 * Kafka module outputs
 */

output "zk_connect" {
  value = "${join(",", formatlist("%s:2181", aws_instance.zookeeper-server.*.private_ip))}"
}

output "first_zk_addr" {
 value = "${format("%s:2181", aws_instance.zookeeper-server.0.private_ip)}"
}

output "kafka_brokers_list" {
  value = "${join(",", formatlist("%s:9092", aws_instance.kafka-server.*.private_ip))}"
}

output "first_kafka_broker" {
  value = "${format("%s:9092", aws_instance.kafka-server.0.private_ip)}"
}

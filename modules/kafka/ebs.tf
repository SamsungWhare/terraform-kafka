/*
 * Kafka EBS configuration
 */

resource "aws_volume_attachment" "ebs" {
  count       = "${aws_instance.kafka-server.count}"
  device_name = "${var.ebs_device_name}"
  volume_id   = "${length(var.ebs_volume_ids) > 0 ? element(concat(var.ebs_volume_ids, list("")), count.index) : element(aws_ebs_volume.staging.*.id, count.index)}"
  instance_id = "${element(aws_instance.kafka-server.*.id, count.index)}"
}

resource "aws_ebs_volume" "staging" {
  count             = 3
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  size              = 1
}
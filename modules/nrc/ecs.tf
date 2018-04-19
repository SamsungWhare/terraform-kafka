resource "aws_ecs_cluster" "nrc" {
  name = "nrc-${terraform.workspace}"
}

data "aws_ecs_task_definition" "nrc" {
  task_definition = "${aws_ecs_task_definition.nrc.family}"
}

resource "aws_ecs_task_definition" "nrc" {
  family = "nrc_${var.docker_image_tag}"
  container_definitions = <<DEFINITION
[
  {
    "name": "nrc",
    "image": "${data.aws_ecr_repository.nrc.repository_url}:${var.docker_image_tag}",
    "cpu": 1024,
    "memory": 1024,
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000,
        "protocol": "tcp"
      },
      {
        "containerPort": 61022,
        "hostPort": 61022,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "entryPoint": [
      "go",
      "run",
      "main.go",
      "-connecttcp",
      "server",
      "-port",
      "61022",
      "-kafkabroker",
      "${var.kafka_brokers}"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/nrc",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "nrc" {
  name            = "nrc"
  cluster         = "${aws_ecs_cluster.nrc.arn}"
  task_definition = "${data.aws_ecs_task_definition.nrc.arn}"
  desired_count   = "${var.nrc_instance_count}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
  task_definition = "${aws_ecs_task_definition.nrc.family}:${max("${aws_ecs_task_definition.nrc.revision}", "${data.aws_ecs_task_definition.nrc.revision}")}"
}

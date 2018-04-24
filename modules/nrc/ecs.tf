resource "aws_ecs_cluster" "nrc" {
  name = "nrc-${var.environment}-${var.nrc_namespace}"
}

resource "aws_ecs_task_definition" "nrc" {
  family                   = "nrc_${var.docker_image_tag}"
  task_role_arn            = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  network_mode             = "bridge"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["EC2"]
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
  desired_count   = "${var.nrc_instance_count}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
  task_definition = "${aws_ecs_task_definition.nrc.family}:${aws_ecs_task_definition.nrc.revision}"
}

data "aws_iam_role" "ecs_ingest" {
  name = "ecs_ingest"
}

data "aws_security_group" "ecs_nrc" {
  id = "sg-7789513e"
}

# data "aws_iam_instance_profile" "ecs_nrc" {
#   name = "ingest_profile"
# }

resource "aws_instance" "ingest" {
  ami                    = "ami-aff65ad2"
  instance_type          = "${var.nrc_instance_type}"
  availability_zone      = "us-east-1a"
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.nrc.name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile   = "ingest_profile"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_nrc.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

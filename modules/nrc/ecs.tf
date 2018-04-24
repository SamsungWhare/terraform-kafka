resource "aws_ecs_cluster" "nrc" {
  name = "nrc-${var.environment}-${var.nrc_namespace}"
}

resource "aws_iam_role" "nrc_ec2" {
  name = "nrc_ec2_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}



resource "aws_ecs_task_definition" "nrc" {
  family                   = "nrc_${var.docker_image_tag}"
  task_role_arn            = "${aws_iam_role.nrc_ec2.arn}"
  execution_role_arn       = "${aws_iam_role.nrc_ec2.arn}"
  network_mode             = "bridge"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["EC2"]
  depends_on               = ["aws_iam_role.nrc_ec2"]
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
        "awslogs-region": "${data.aws_region.current.name}",
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
  depends_on      = ["aws_iam_role.nrc_ec2"]

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${data.aws_availability_zones.available.names[0]}]"
  }
  task_definition = "${aws_ecs_task_definition.nrc.family}:${aws_ecs_task_definition.nrc.revision}"
}

resource "aws_instance" "ingest" {
  ami                    = "ami-aff65ad2"
  instance_type          = "${var.nrc_instance_type}"
  availability_zone      = "${data.aws_availability_zones.available.names[0]}"
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.nrc.name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile   = "ingest_profile"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
}

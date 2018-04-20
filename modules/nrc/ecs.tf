resource "aws_ecs_cluster" "nrc" {
  name = "nrc-${var.environment}-${terraform.workspace}"
}

# data "aws_ecs_task_definition" "nrc" {
#   task_definition = "${aws_ecs_task_definition.nrc.family}"
# }

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
  # iam_role        = "arn:aws:iam::489114792760:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  # task_definition = "${data.aws_ecs_task_definition.nrc.arn}"
  desired_count   = "${var.nrc_instance_count}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
  task_definition = "${aws_ecs_task_definition.nrc.family}:${aws_ecs_task_definition.nrc.revision}"
}

resource "aws_iam_role" "ecs_ingest" {
  name = "ecs_ingest"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy" "ecs_ingest" { 
  name = "ecs_instance_role"
  role = "${aws_iam_role.ecs_ingest.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ingest" {
  name = "ingest_profile"
  role = "${aws_iam_role.ecs_ingest.name}"
}

data "aws_security_group" "ecs_nrc" {
  id = "sg-7789513e"
}

resource "aws_instance" "ingest" {
  ami                    = "ami-aff65ad2"
  instance_type          = "m4.large"
  availability_zone      = "us-east-1a"
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.nrc.name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile   = "${aws_iam_instance_profile.ingest.name}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_nrc.id}"]
}

resource "aws_ecs_cluster" "instance" {
  name = "${var.environment}-${var.namespace}"
}

resource "aws_ecs_task_definition" "api" {
  family                   = "api_${var.api_docker_image_tag}"
  task_role_arn            = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = <<DEFINITION
[
  {
    "name": "api",
    "image": "${data.aws_ecr_repository.api.repository_url}:${var.api_docker_image_tag}",
    "cpu": 1024,
    "memory": 1024,
    "environment": [
      { "name": "NRC_HOST", "value": "http://nrc.whare-dev.com" },
      { "name": "REDIS_HOST", "value": "${var.redis_host}" },
      { "name": "KAFKA_BROKER", "value": "${var.kafka_brokers}" },
      { "name": "ZOOKEEPER_HOST", "value": "${var.zk_host}" },
      { "name": "VIRTUAL_OBJECT_ASSET_S3_BUCKET", "value": "whare-models-dev" },
      { "name": "API_DB_HOST", "value": "${data.aws_db_instance.api.address}" },
      { "name": "API_DB_NAME", "value": "apidb" },
      { "name": "API_DB_USER", "value": "dbmaster" },
      { "name": "API_DB_PASSWORD", "value": "${data.aws_secretsmanager_secret_version.api_dev_db.secret_string}" },
      { "name": "AWS_ACCESS_KEY_KEY_ID", "value": "AKIAJ3RZZCT57PSZOKKQ" },
      { "name": "AWS_SECRET_ACCESS_KEY", "value": "${data.aws_secretsmanager_secret_version.s3.secret_string}" }
    ],
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "entryPoint": [
      "gunicorn",
      "api.wsgi_dev_deploy",
      "--bind",
      "0.0.0.0:8000"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/api",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "nrc" {
  family                   = "nrc_${var.nrc_docker_image_tag}"
  task_role_arn            = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::489114792760:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = <<DEFINITION
[
  {
    "name": "nrc",
    "image": "${data.aws_ecr_repository.nrc.repository_url}:${var.nrc_docker_image_tag}",
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

resource "aws_ecs_service" "api" {
  name            = "api"
  cluster         = "${aws_ecs_cluster.instance.arn}"
  desired_count   = "${var.api_instance_count}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
  task_definition = "${aws_ecs_task_definition.api.family}:${aws_ecs_task_definition.api.revision}"

  network_configuration {
    subnets = ["subnet-c19f3bee"]
    security_groups = ["${data.aws_security_group.ecs_nrc.id}"]
  }
}

resource "aws_ecs_service" "nrc" {
  name            = "nrc"
  cluster         = "${aws_ecs_cluster.instance.arn}"
  desired_count   = "${var.nrc_instance_count}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
  task_definition = "${aws_ecs_task_definition.nrc.family}:${aws_ecs_task_definition.nrc.revision}"

  network_configuration {
    subnets = ["subnet-c19f3bee"]
    security_groups = ["${data.aws_security_group.ecs_nrc.id}"]
  }
}

data "aws_iam_role" "ecs_ingest" {
  name = "ecs_ingest"
}

data "aws_security_group" "ecs_nrc" {
  id = "sg-7789513e"
}

/* We can reduce the count if/when we change docker port mapping to use dynamic port assignment so
   multiple tasks can run on the same container instance potentially */
resource "aws_instance" "ingest" {
  count                  = "${var.api_instance_count + var.nrc_instance_count}"
  ami                    = "ami-aff65ad2"
  instance_type          = "${var.nrc_instance_type}"
  key_name               = "${var.key_name}"
  availability_zone      = "us-east-1a"
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.instance.name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile   = "ingest_profile"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_nrc.id}"]

  tags {
    Name = "ECS--${aws_ecs_cluster.instance.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

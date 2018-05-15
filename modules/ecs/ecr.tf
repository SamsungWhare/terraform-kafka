data "aws_ecr_repository" "nrc" {
  name = "samsungwhare/nrc"
}

data "aws_ecr_repository" "api" {
  name = "samsungwhare/api"
}

resource "aws_ecr_lifecycle_policy" "api_policy" {
  repository = "${data.aws_ecr_repository.api.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 40 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 40
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "nrc_policy" {
  repository = "${data.aws_ecr_repository.nrc.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 40 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 40
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

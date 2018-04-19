data "aws_ecr_repository" "nrc" {
  name = "samsungwhare/nrc"
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

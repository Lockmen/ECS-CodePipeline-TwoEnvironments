# CloudWatch Log Group for CodeBuild
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/demo-build-push"
  retention_in_days = 7
}

# CodeBuild project for building and pushing Docker image
resource "aws_codebuild_project" "build_and_push" {
  name          = "demo-build-push"
  description   = "Build Docker image and push to ECR"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  artifacts { type = "CODEPIPELINE" }
  source { type = "CODEPIPELINE" }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_REPOSITORY_URL"
      value = aws_ecr_repository.demo_app.repository_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "build-logs"
    }
  }
}
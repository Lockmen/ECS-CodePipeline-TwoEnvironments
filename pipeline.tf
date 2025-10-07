resource "aws_codepipeline" "main" {
  name     = "demo-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_staging.bucket
    type     = "S3"
  }

  # Stage 1: Source - Pull code from GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codeconnections_connection.github.arn
        FullRepositoryId = "ppabis/demo-app-repo"
        BranchName       = "main"
        DetectChanges    = true
      }
    }
  }

  # ... Next steps will follow
}
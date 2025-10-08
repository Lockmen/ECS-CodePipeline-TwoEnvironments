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
        FullRepositoryId = "ppabis/demo-app"
        BranchName       = "master"
        DetectChanges    = true
      }
    }
  }

  # Stage 2: Build - Build Docker image and push to ECR
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_and_push.name
      }
    }
  }

  # Stage 3: Deploy - Deploy to ECS
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = module.ecs.cluster_name
        ServiceName = module.ecs.services["dev"].name
        FileName    = "imagespec.json"
      }
    }
  }
}
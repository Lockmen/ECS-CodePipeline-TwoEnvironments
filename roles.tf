# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "demo-codepipeline-role"
  assume_role_policy = templatefile("policies/assume.json", {
    service_name = "codepipeline"
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "demo-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id
  policy = templatefile("policies/codepipeline.json", {
    bucket_name = aws_s3_bucket.codepipeline_staging.id
  })
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "demo-codebuild-role"
  assume_role_policy = templatefile("policies/assume.json", {
    service_name = "codebuild"
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "demo-codebuild-policy"
  role = aws_iam_role.codebuild_role.id
  policy = templatefile("policies/codebuild.json", {
    bucket_name = aws_s3_bucket.codepipeline_staging.id
  })
}
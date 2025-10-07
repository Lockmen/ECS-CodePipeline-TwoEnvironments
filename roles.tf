# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name               = "demo-codepipeline-role"
  assume_role_policy = templatefile("policies/assume_codepipeline.json", {
    service_name = "codepipeline"
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "demo-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = templatefile("policies/codepipeline.json", {
    bucket_name = aws_s3_bucket.codepipeline_staging.id
  })
}
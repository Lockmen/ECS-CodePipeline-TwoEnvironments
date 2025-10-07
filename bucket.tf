resource "aws_s3_bucket" "codepipeline_staging" {
  bucket        = "pipeline-99819188-makeitunique"
  force_destroy = true
}
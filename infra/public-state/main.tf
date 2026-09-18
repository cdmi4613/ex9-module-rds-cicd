# ################################################################################
# Terraform State S3 Bucket
# ################################################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "bipa17-std01-ex9-terraform-state"

  tags = {
    Name = "bipa17-std01-ex9-terraform-state"
  }
}


# ################################################################################
# S3 Versioning
# ################################################################################

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "backup_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket = "${var.namespace}-velero-backup"

  versioning = {
    enabled = true
  }
}

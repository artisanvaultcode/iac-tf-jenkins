#Set S3 backend for persisting TF state file remotely, ensure bucket already exits
# And that AWS user being used by TF has read/write perms
terraform {
  required_version = ">=1.5.7"
  required_providers {
    aws = ">=5.31.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "iacdev"
    key     = "tf-statefile"
    bucket  = "meng-tfstate"
  }
}
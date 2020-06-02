provider "aws" {
  version = ">= 2.53"
  region  = var.AWS_REGION
}

terraform {
  required_version = ">= 0.12"

  backend "remote" {
    organization = "testapp"

    workspaces {
      name = "dev"
    }
  }
}

module "vpc" {
  source = "./vpc"

  app_name = var.app_name
}

#####
# IAM
#####
// Create new IAM Role with s3, secretsmanager and RDS access
# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ec2_s3_secretmanager_role" {
#   name               = "s3-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "aws_iam_policy_document" "policy" {
# statement {
#   sid = "1"
#   actions = [
#     "secretsmanager:GetResourcePolicy",
#     "secretsmanager:GetSecretValue",
#     "secretsmanager:DescribeSecret",
#     "secretsmanager:ListSecretVersionIds"
#   ]
#   resources = [
#     "${aws_secretsmanager_secret.TestAppSecret3.arn}",
#   ]
# }

# statement {
#   sid = "2"
#   actions = [
#     "secretsmanager:GetRandomPassword",
#     "secretsmanager:ListSecrets"
#   ]
#   resources = [
#     aws_secretsmanager_secret_version.TestAppCredentials3.arn
#   ]
# }

# statement {
#   sid = "3"
#   actions = [
#     "rds:*"
#   ]
#   resources = [
#     module.db.arn
#   ]
# }

# statement {
#   sid = "4"
#   actions = [
#     "s3:GetAccessPoint",
#     "s3:GetLifecycleConfiguration",
#     "s3:GetBucketTagging",
#     "s3:GetInventoryConfiguration",
#     "s3:GetObjectVersionTagging",
#     "s3:ListBucketVersions",
#     "s3:GetBucketLogging",
#     "s3:ListBucket",
#     "s3:GetAccelerateConfiguration",
#     "s3:GetBucketPolicy",
#     "s3:GetObjectVersionTorrent",
#     "s3:GetObjectAcl",
#     "s3:GetEncryptionConfiguration",
#     "s3:GetBucketObjectLockConfiguration",
#     "s3:GetBucketRequestPayment",
#     "s3:GetAccessPointPolicyStatus",
#     "s3:GetObjectVersionAcl",
#     "s3:GetObjectTagging",
#     "s3:GetMetricsConfiguration",
#     "s3:HeadBucket",
#     "s3:GetBucketPublicAccessBlock",
#     "s3:GetBucketPolicyStatus",
#     "s3:ListBucketMultipartUploads",
#     "s3:GetObjectRetention",
#     "s3:GetBucketWebsite",
#     "s3:ListAccessPoints",
#     "s3:ListJobs",
#     "s3:GetBucketVersioning",
#     "s3:GetBucketAcl",
#     "s3:GetObjectLegalHold",
#     "s3:GetBucketNotification",
#     "s3:GetReplicationConfiguration",
#     "s3:ListMultipartUploadParts",
#     "s3:GetObject",
#     "s3:GetObjectTorrent",
#     "s3:GetAccountPublicAccessBlock",
#     "s3:ListAllMyBuckets",
#     "s3:DescribeJob",
#     "s3:GetBucketCORS",
#     "s3:GetAnalyticsConfiguration",
#     "s3:GetObjectVersionForReplication",
#     "s3:GetBucketLocation",
#     "s3:GetAccessPointPolicy",
#     "s3:GetObjectVersion"
#   ]
#   resources = [
#     "*"
#   ]
#   }
# }

# resource "aws_iam_policy" "policy" {
#   name        = "${var.app_name}_policy"
#   description = "${var.app_name} policy"
#   # policy      = data.aws_iam_policy_document.policy.json
# }

# resource "aws_iam_policy_attachment" "test_attach" {
#   name       = "test_attachment"
#   roles      = [aws_iam_role.ec2_s3_secretmanager_role.name]
#   policy_arn = aws_iam_policy.policy.arn
# }

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.ec2_s3_secretmanager_role.name
# }


resource "aws_efs_file_system" "default" {
  count                           = var.enabled ? 1 : 0
  tags                            = var.tags
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
}

resource "aws_efs_mount_target" "default" {
  count           = var.enabled && length(var.subnets) > 0 ? length(var.subnets) : 0
  file_system_id  = join("", aws_efs_file_system.default.*.id)
  subnet_id       = var.subnets[count.index]
#   security_groups = [var.security_groups]
#   security_groups = [join("", aws_security_group.efs.*.id)]
  security_groups = [join("", var.security_groups)]
}

resource "aws_efs_file_system_policy" "policy" {
  count                           = var.enabled ? 1 : 0
  file_system_id = "${aws_efs_file_system.default[count.index].id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleSatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.default[count.index].arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}


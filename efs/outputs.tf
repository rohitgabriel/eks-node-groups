output "efs_arn" {
  value = aws_efs_file_system.default[0].arn
}

output "efs_fs_id" {
  value = aws_efs_file_system.default[0].id
}
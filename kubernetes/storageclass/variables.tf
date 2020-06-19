variable "efs_volumehandle" {
  description = "EFS volume handle"
  type        = string
}

variable "kube_depends_on" {
  description = "Dummy variable to invoke dependency"
  type        = list
}
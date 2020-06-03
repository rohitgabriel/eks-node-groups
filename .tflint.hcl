config {
  module     = true
  deep_check = false
  force      = true
}

rule "terraform_dash_in_resource_name" {
  enabled = true
}
rule "terraform_dash_in_output_name" {
  enabled = true
}
rule "terraform_deprecated_interpolation" {
  enabled = true
}
rule "terraform_documented_outputs" {
  enabled = true
}
rule "terraform_documented_variables" {
  enabled = true
}
rule "terraform_module_pinned_source" {
  enabled = true
}
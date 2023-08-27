variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "enforce_kms_policy" {
  type    = bool
  default = false
}

variable "mfa_policy_enabled" {
  type    = bool
  default = false
}

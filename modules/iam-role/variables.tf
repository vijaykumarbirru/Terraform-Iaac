variable "name" {
  description = "IAM role name"
  type        = string
}

variable "description" {
  description = "IAM role description"
  type        = string
  default     = null
}

variable "policy_arns" {
  description = "List of IAM managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline IAM policies"
  type        = map(any)
  default     = {}
}

variable "assume_role_policy" {
  description = "JSON string for the trust relationship"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}

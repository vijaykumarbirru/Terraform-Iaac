variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Enable AWS ECR image vulnerability scanning"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "lifecycle_policy" {
  description = "JSON lifecycle policy for ECR cleanup"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for ECR"
  type        = map(string)
  default     = {}
}

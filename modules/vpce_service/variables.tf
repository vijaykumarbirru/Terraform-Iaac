variable "name" {
  description = "Name prefix for the VPC Endpoint Service"
  type        = string
}

variable "nlb_arn" {
  description = "ARN of the internal NLB"
  type        = string
}

variable "allowed_principals" {
  description = "IAM principals (AWS accounts) allowed to create Interface Endpoints"
  type        = list(string)
  default     = []
}

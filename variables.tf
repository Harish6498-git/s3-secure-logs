variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique). If empty, a name will be generated."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "Optional existing KMS key ARN or ID to use for S3 encryption. If empty, module will create a CMK."
  type        = string
  default     = ""
}

variable "create_kms" {
  description = "If true and kms_key_id is empty, module will create a KMS CMK. If false and kms_key_id is empty, S3 will use aws-managed KMS (not recommended for audit)."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "If true, the bucket will be destroyed even if it contains objects (use carefully)."
  type        = bool
  default     = false
}

variable "transition_days" {
  description = "Days after which objects transition to Glacier."
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Days after which objects expire."
  type        = number
  default     = 365
}

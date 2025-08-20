output "bucket_id" {
  description = "S3 bucket id (name)"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket arn"
  value       = aws_s3_bucket.this.arn
}

output "kms_key_id" {
  description = "KMS key ARN used for encryption (if created by module, returns created key ARN)"
  value       = local.kms_key_id_final
  sensitive   = false
}

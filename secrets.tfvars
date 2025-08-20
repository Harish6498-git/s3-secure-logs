# secrets.tfvars (example)
# Optional: use an existing KMS key instead of creating one
kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd-ef01-2345-6789"

# Optionally override bucket_name (not secret, but convenient here)
bucket_name = "harish-secure-logs-2025-08-20"

# Dangerous: set true only if you want terraform destroy to remove objects
force_destroy = false

# You could also override lifecycle values if needed
transition_days  = 30
expiration_days  = 365

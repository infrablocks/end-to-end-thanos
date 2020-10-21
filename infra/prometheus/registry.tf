data "terraform_remote_state" "registry" {
  backend = "s3"

  config = {
    bucket = var.registry_state_bucket_name
    key = var.registry_state_key
    region = var.registry_state_bucket_region
    encrypt = var.registry_state_bucket_is_encrypted
  }
}

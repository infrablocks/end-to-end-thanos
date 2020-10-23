locals {
  thanos_query_env_file_object_key = "thanos-query/service/environments/default.env"
}

data "template_file" "thanos_query_env_file_object_path" {
  template = "s3://$${secrets_bucket}/$${environment_object_key}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    environment_object_key = local.thanos_query_env_file_object_key
  }
}

data "template_file" "thanos_query_env" {
  template = file("${path.root}/envfiles/thanos-query.env")

  vars = {
    thanos_http_address = "0.0.0.0:${var.thanos_query_container_http_port}"
    thanos_grpc_address = "0.0.0.0:${var.thanos_query_container_grpc_port}"
    thanos_store_addresses = "dnssrv+${data.terraform_remote_state.registry.outputs.service_discovery_prometheus_address},dnssrv+${data.terraform_remote_state.registry.outputs.service_discovery_thanos_store_address}"
    thanos_query_replica_labels = join(",", var.thanos_query_replica_labels)
  }
}

resource "aws_s3_bucket_object" "thanos_sidecar_env" {
  key = local.thanos_query_env_file_object_key
  bucket = var.secrets_bucket_name
  content = data.template_file.thanos_query_env.rendered

  server_side_encryption = "AES256"
}

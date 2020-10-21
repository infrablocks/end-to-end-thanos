locals {
  prometheus_env_file_object_key = "prometheus/service/${var.instance}/environments/default.env"
  prometheus_configuration_file_object_path = "prometheus/service/${var.instance}/configuration/prometheus.yml"
  thanos_sidecar_env_file_object_key = "thanos-sidecar/service/${var.instance}/environments/default.env"
  thanos_sidecar_object_store_configuration_file_object_key = "thanos-sidecar/service/${var.instance}/configuration/object-store.yml"
}

data "template_file" "prometheus_env_file_object_path" {
  template = "s3://$${secrets_bucket}/$${environment_object_key}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    environment_object_key = local.prometheus_env_file_object_key
  }
}

data "template_file" "prometheus_configuration_file_object_path" {
  template = "s3://$${secrets_bucket}/$${configuration_file_object_path}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    configuration_file_object_path = local.prometheus_configuration_file_object_path
  }
}

data "template_file" "thanos_sidecar_env_file_object_path" {
  template = "s3://$${secrets_bucket}/$${environment_object_key}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    environment_object_key = local.thanos_sidecar_env_file_object_key
  }
}

data "template_file" "thanos_sidecar_object_store_configuration_file_object_path" {
  template = "s3://$${secrets_bucket}/$${configuration_file_object_path}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    configuration_file_object_path = local.thanos_sidecar_object_store_configuration_file_object_key
  }
}

data "template_file" "prometheus_env" {
  template = file("${path.root}/envfiles/prometheus.env")

  vars = {
    prometheus_configuration_file_object_path = data.template_file.prometheus_configuration_file_object_path.rendered
  }
}

data "template_file" "prometheus_configuration" {
  template = file("${path.root}/configuration/prometheus.yml")

  vars = {
    instance = var.instance
  }
}

data "template_file" "thanos_sidecar_env" {
  template = file("${path.root}/envfiles/thanos-sidecar.env")

  vars = {
    prometheus_host_http_port = var.prometheus_host_http_port
    thanos_object_store_configuration_file_object_path = data.template_file.thanos_sidecar_object_store_configuration_file_object_path.rendered
    thanos_http_address = "0.0.0.0:${var.thanos_sidecar_container_http_port}"
    thanos_grpc_address = "0.0.0.0:${var.thanos_sidecar_container_grpc_port}"
  }
}

data "template_file" "thanos_sidecar_object_store_configuration" {
  template = file("${path.root}/configuration/object-store.yml")

  vars = {
    storage_bucket_name = var.prometheus_storage_bucket_name
    storage_bucket_region = var.prometheus_storage_bucket_region
  }
}

resource "aws_s3_bucket_object" "prometheus_env" {
  key = local.prometheus_env_file_object_key
  bucket = var.secrets_bucket_name
  content = data.template_file.prometheus_env.rendered

  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "prometheus_configuration" {
  key = local.prometheus_configuration_file_object_path
  bucket = var.secrets_bucket_name
  content = data.template_file.prometheus_configuration.rendered

  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "thanos_sidecar_env" {
  key = local.thanos_sidecar_env_file_object_key
  bucket = var.secrets_bucket_name
  content = data.template_file.thanos_sidecar_env.rendered

  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "thanos_sidecar_object_store_configuration" {
  key = local.thanos_sidecar_object_store_configuration_file_object_key
  bucket = var.secrets_bucket_name
  content = data.template_file.thanos_sidecar_object_store_configuration.rendered

  server_side_encryption = "AES256"
}

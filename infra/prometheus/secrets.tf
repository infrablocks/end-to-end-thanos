locals {
  env_file_object_key = "prometheus/service/environments/default.env"
  configuration_file_object_path = "prometheus/service/configuration/prometheus.yml"
}

data "template_file" "env_file_object_path" {
  template = "s3://$${secrets_bucket}/$${environment_object_key}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    environment_object_key = local.env_file_object_key
  }
}

data "template_file" "configuration_file_object_path" {
  template = "s3://$${secrets_bucket}/$${configuration_file_object_path}"

  vars = {
    secrets_bucket = var.secrets_bucket_name
    configuration_file_object_path = local.configuration_file_object_path
  }
}

data "template_file" "env" {
  template = file("${path.root}/envfiles/prometheus.env.tpl")

  vars = {
    prometheus_configuration_file_object_path = data.template_file.configuration_file_object_path.rendered
  }
}

data "template_file" "configuration" {
  template = file("${path.root}/configuration/prometheus.yml.tpl")

  vars = {

  }
}

resource "aws_s3_bucket_object" "env" {
  key = local.env_file_object_key
  bucket = var.secrets_bucket_name
  content = data.template_file.env.rendered

  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "configuration" {
  key = local.configuration_file_object_path
  bucket = var.secrets_bucket_name
  content = data.template_file.configuration.rendered

  server_side_encryption = "AES256"
}

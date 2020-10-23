variable "region" {}
variable "component" {}
variable "deployment_identifier" {}

variable "instance" {}

variable "service_desired_count" {}

variable "secrets_bucket_name" {}
variable "storage_bucket_name" {}
variable "storage_bucket_region" {}

variable "prometheus_service_name" {}
variable "prometheus_image" {}
variable "prometheus_container_http_port" {}
variable "prometheus_host_http_port" {}

variable "prometheus_storage_tsdb_retention_time" {}
variable "prometheus_storage_location" {}

variable "thanos_sidecar_image" {}
variable "thanos_sidecar_container_http_port" {}
variable "thanos_sidecar_host_http_port" {}
variable "thanos_sidecar_container_grpc_port" {}
variable "thanos_sidecar_host_grpc_port" {}

variable "thanos_store_service_name" {}
variable "thanos_store_image" {}
variable "thanos_store_container_http_port" {}
variable "thanos_store_host_http_port" {}
variable "thanos_store_container_grpc_port" {}
variable "thanos_store_host_grpc_port" {}
variable "thanos_store_storage_location" {}

variable "thanos_compact_service_name" {}
variable "thanos_compact_image" {}
variable "thanos_compact_container_http_port" {}
variable "thanos_compact_host_http_port" {}
variable "thanos_compact_storage_location" {}

variable "domain_state_bucket_name" {}
variable "domain_state_key" {}
variable "domain_state_bucket_region" {}
variable "domain_state_bucket_is_encrypted" {}

variable "network_state_bucket_name" {}
variable "network_state_key" {}
variable "network_state_bucket_region" {}
variable "network_state_bucket_is_encrypted" {}

variable "cluster_state_bucket_name" {}
variable "cluster_state_key" {}
variable "cluster_state_bucket_region" {}
variable "cluster_state_bucket_is_encrypted" {}

variable "registry_state_bucket_name" {}
variable "registry_state_key" {}
variable "registry_state_bucket_region" {}
variable "registry_state_bucket_is_encrypted" {}

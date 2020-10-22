variable "region" {}
variable "component" {}
variable "deployment_identifier" {}

variable "service_desired_count" {}

variable "secrets_bucket_name" {}

variable "thanos_query_service_name" {}
variable "thanos_query_image" {}
variable "thanos_query_container_http_port" {}
variable "thanos_query_host_http_port" {}
variable "thanos_query_container_grpc_port" {}
variable "thanos_query_host_grpc_port" {}
variable "thanos_query_replica_label" {}

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

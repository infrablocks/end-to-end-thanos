locals {
  prometheus_container_name = "prometheus"
  thanos_sidecar_container_name = "thanos-sidecar"
  thanos_compact_container_name = "thanos-compact"
  thanos_store_container_name = "thanos-store"
}

resource "aws_cloudwatch_log_group" "prometheus" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.prometheus_service_name}/containers/${local.prometheus_container_name}"

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component = var.component
    Service = var.component
    Instance = var.instance
    Container = local.prometheus_container_name
  }
}

resource "aws_cloudwatch_log_group" "thanos_sidecar" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.prometheus_service_name}/containers/${local.thanos_sidecar_container_name}"

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component = var.component
    Service = var.component
    Instance = var.instance
    Container = local.thanos_sidecar_container_name
  }
}

resource "aws_cloudwatch_log_group" "thanos_compact" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.thanos_compact_service_name}/containers/${local.thanos_compact_container_name}"

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component = var.component
    Service = var.component
    Instance = var.instance
    Container = local.thanos_compact_container_name
  }
}

resource "aws_cloudwatch_log_group" "thanos_store" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.thanos_store_service_name}/containers/${local.thanos_store_container_name}"

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component = var.component
    Service = var.component
    Instance = var.instance
    Container = local.thanos_store_container_name
  }
}

data "template_file" "prometheus_task_container_definitions" {
  template = file("${path.root}/container-definitions/prometheus.json.tpl")

  vars = {
    prometheus_container_name = local.prometheus_container_name
    prometheus_container_image = var.prometheus_image
    prometheus_container_http_port = var.prometheus_container_http_port
    prometheus_host_http_port = var.prometheus_host_http_port
    prometheus_env_file_object_path = data.template_file.prometheus_env_file_object_path.rendered
    prometheus_storage_location = var.prometheus_storage_location
    prometheus_log_group = aws_cloudwatch_log_group.prometheus.name

    thanos_sidecar_container_name = local.thanos_sidecar_container_name
    thanos_sidecar_container_image = var.thanos_sidecar_image
    thanos_sidecar_container_http_port = var.thanos_sidecar_container_http_port
    thanos_sidecar_host_http_port = var.thanos_sidecar_host_http_port
    thanos_sidecar_container_grpc_port = var.thanos_sidecar_container_grpc_port
    thanos_sidecar_host_grpc_port = var.thanos_sidecar_host_grpc_port
    thanos_sidecar_env_file_object_path = data.template_file.thanos_sidecar_env_file_object_path.rendered
    thanos_sidecar_log_group = aws_cloudwatch_log_group.thanos_sidecar.name
  }
}

data "template_file" "thanos_compact_task_container_definitions" {
  template = file("${path.root}/container-definitions/thanos-compact.json.tpl")

  vars = {
    thanos_compact_container_name = local.thanos_compact_container_name
    thanos_compact_container_image = var.thanos_compact_image
    thanos_compact_container_http_port = var.thanos_compact_container_http_port
    thanos_compact_host_http_port = var.thanos_compact_host_http_port
    thanos_compact_env_file_object_path = data.template_file.thanos_compact_env_file_object_path.rendered
    thanos_compact_storage_location = var.thanos_compact_storage_location
    thanos_compact_log_group = aws_cloudwatch_log_group.thanos_compact.name
  }
}

data "template_file" "thanos_store_task_container_definitions" {
  template = file("${path.root}/container-definitions/thanos-store.json.tpl")

  vars = {
    thanos_store_container_name = local.thanos_store_container_name
    thanos_store_container_image = var.thanos_store_image
    thanos_store_container_http_port = var.thanos_store_container_http_port
    thanos_store_host_http_port = var.thanos_store_host_http_port
    thanos_store_container_grpc_port = var.thanos_store_container_grpc_port
    thanos_store_host_grpc_port = var.thanos_store_host_grpc_port
    thanos_store_env_file_object_path = data.template_file.thanos_store_env_file_object_path.rendered
    thanos_store_storage_location = var.thanos_store_storage_location
    thanos_store_log_group = aws_cloudwatch_log_group.thanos_store.name
  }
}

module "prometheus_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "3.3.0-rc.1"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.aws_vpc.vpc.id

  service_task_container_definitions = data.template_file.prometheus_task_container_definitions.rendered

  service_name = var.prometheus_service_name
  service_image = var.prometheus_image
  service_port = var.prometheus_container_http_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 0

  service_role = aws_iam_role.service_role.arn

  register_in_service_discovery = "yes"
  service_discovery_create_registry = "no"
  service_discovery_registry_arn = data.terraform_remote_state.registry.outputs.service_discovery_prometheus_service_registry_arn
  service_discovery_container_name = local.thanos_sidecar_container_name
  service_discovery_container_port = var.thanos_sidecar_container_grpc_port

  service_volumes = [
    {
      name = "prometheus-storage"
      host_path = var.prometheus_storage_location
    }
  ]

  placement_constraints = [
    {
      type: "distinctInstance",
      expression: null
    },
    {
      type: "memberOf",
      expression: "attribute:ecs.availability-zone == ${data.terraform_remote_state.network.outputs.availability_zones[var.instance - 1]}"
    }
  ]

  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.cluster.outputs.ecs_service_role_arn

  attach_to_load_balancer = "no"
  include_log_group = "no"
}

module "thanos_compact_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "3.3.0-rc.1"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.aws_vpc.vpc.id

  service_task_container_definitions = data.template_file.thanos_compact_task_container_definitions.rendered

  service_name = var.thanos_compact_service_name
  service_image = var.thanos_compact_image
  service_port = var.thanos_compact_container_http_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 0

  service_role = aws_iam_role.service_role.arn

  service_volumes = [
    {
      name = "thanos-compact-storage"
      host_path = var.thanos_compact_storage_location
    }
  ]

  placement_constraints = [
    {
      type: "distinctInstance",
      expression: null
    },
    {
      type: "memberOf",
      expression: "attribute:ecs.availability-zone == ${data.terraform_remote_state.network.outputs.availability_zones[var.instance - 1]}"
    }
  ]

  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.cluster.outputs.ecs_service_role_arn

  attach_to_load_balancer = "no"
  include_log_group = "no"
}

module "thanos_store_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "3.3.0-rc.1"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.aws_vpc.vpc.id

  service_task_container_definitions = data.template_file.thanos_store_task_container_definitions.rendered

  service_name = var.thanos_store_service_name
  service_image = var.thanos_store_image
  service_port = var.thanos_store_container_http_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 0

  service_role = aws_iam_role.service_role.arn

  register_in_service_discovery = "yes"
  service_discovery_create_registry = "no"
  service_discovery_registry_arn = data.terraform_remote_state.registry.outputs.service_discovery_thanos_store_service_registry_arn
  service_discovery_container_name = local.thanos_store_container_name
  service_discovery_container_port = var.thanos_store_container_grpc_port

  service_volumes = [
    {
      name = "thanos-store-storage"
      host_path = var.thanos_store_storage_location
    }
  ]

  placement_constraints = [
    {
      type: "distinctInstance",
      expression: null
    },
    {
      type: "memberOf",
      expression: "attribute:ecs.availability-zone == ${data.terraform_remote_state.network.outputs.availability_zones[var.instance - 1]}"
    }
  ]

  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.cluster.outputs.ecs_service_role_arn

  attach_to_load_balancer = "no"
  include_log_group = "no"
}

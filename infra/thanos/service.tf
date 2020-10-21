locals {
  thanos_query_container_name = "thanos-query"
}

resource "aws_cloudwatch_log_group" "thanos_query" {
  name = "/${var.component}/${var.deployment_identifier}/ecs-service/${var.service_name}/containers/${local.thanos_query_container_name}"

  tags = {
    DeploymentIdentifier = var.deployment_identifier
    Component = var.component
    Service = var.component
    Container = local.thanos_query_container_name
  }
}

data "template_file" "thanos_query_task_container_definitions" {
  template = file("${path.root}/container-definitions/thanos-query.json.tpl")

  vars = {
    thanos_query_container_name = local.thanos_query_container_name
    thanos_query_container_image = var.thanos_query_image
    thanos_query_container_http_port = var.thanos_query_container_http_port
    thanos_query_host_http_port = var.thanos_query_host_http_port
    thanos_query_container_grpc_port = var.thanos_query_container_grpc_port
    thanos_query_host_grpc_port = var.thanos_query_host_grpc_port
    thanos_query_env_file_object_path = data.template_file.thanos_query_env_file_object_path.rendered
    thanos_query_log_group = aws_cloudwatch_log_group.thanos_query.name
  }
}

module "thanos_qyery_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "3.2.0"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.aws_vpc.vpc.id

  service_task_container_definitions = data.template_file.thanos_query_task_container_definitions.rendered

  service_name = var.service_name
  service_image = var.thanos_query_image
  service_port = var.thanos_query_container_http_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 50

  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.cluster.outputs.ecs_service_role_arn

  attach_to_load_balancer = "no"
}

resource "aws_iam_role" "service_role" {
  description        = "prometheus-task-role-${var.component}-${var.deployment_identifier}-${var.instance}"
  assume_role_policy = templatefile("${path.module}/policies/service-assume-role-policy.json.tpl", {})

  tags = {
    Component: var.component
    DeploymentIdentifier: var.deployment_identifier
  }
}

resource "aws_iam_role_policy" "service_policy" {
  role   = aws_iam_role.service_role.id
  policy = templatefile("${path.module}/policies/service-policy.json.tpl", {
    prometheus_storage_bucket_name = var.storage_bucket_name,
    secrets_bucket_name = var.secrets_bucket_name
  })
}

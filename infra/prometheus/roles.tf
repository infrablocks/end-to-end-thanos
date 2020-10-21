resource "aws_iam_role" "prometheus_task_role" {
  description        = "prometheus-task-role-${var.component}-${var.deployment_identifier}-${var.instance}"
  assume_role_policy = templatefile("${path.module}/policies/prometheus-task-assume-role-policy.json.tpl", {})

  tags = {
    Component: var.component
    DeploymentIdentifier: var.deployment_identifier
  }
}

resource "aws_iam_role_policy" "prometheus_task_policy" {
  role   = aws_iam_role.prometheus_task_role.id
  policy = templatefile("${path.module}/policies/prometheus-task-policy.json.tpl", {
    prometheus_storage_bucket_name = var.prometheus_storage_bucket_name,
    secrets_bucket_name = var.secrets_bucket_name
  })
}

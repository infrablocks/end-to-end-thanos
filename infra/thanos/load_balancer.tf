data "aws_acm_certificate" "wildcard" {
  domain = "*.${data.terraform_remote_state.domain.outputs.domain_name}"
  most_recent = true
}

module "load_balancer" {
  source = "infrablocks/application-load-balancer/aws"
  version = "2.4.0-rc.1"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids

  expose_to_public_internet = "yes"

  security_groups = {
    default = {
      associate = "yes"
      ingress_rule = {
        include = "yes"
        cidrs = ["0.0.0.0/0"]
      },
      egress_rule = {
        include = "yes"
        from_port = 0
        to_port = 65535
        cidrs = [data.terraform_remote_state.network.outputs.vpc_cidr]
      }
    }
  }

  dns = {
    domain_name = data.terraform_remote_state.domain.outputs.domain_name
    records = [
      {
        zone_id = data.terraform_remote_state.domain.outputs.public_zone_id
      },
      {
        zone_id = data.terraform_remote_state.domain.outputs.private_zone_id
      }
    ]
  }

  target_groups = [
    {
      key = "default"
      port = var.thanos_query_host_http_port
      protocol = "HTTP"
      target_type = "instance"
      health_check = {
        path = "/-/healthy"
        port = "traffic-port"
        protocol = "HTTP"
        interval = 30
        healthy_threshold = 3
        unhealthy_threshold = 3
      }
    }
  ]

  listeners = [
    {
      key = "default"
      port = "443"
      protocol = "HTTPS"
      certificate_arn = data.aws_acm_certificate.wildcard.arn,
      default_action = {
        type = "forward"
        target_group_key = "default"
      }
    }
  ]
}

module "wildcard_certificate" {
  source  = "infrablocks/acm-certificate/aws"
  version = "0.5.0"

  domain_name = "*.${data.terraform_remote_state.domain.outputs.domain_name}"

  zone_id = data.terraform_remote_state.domain.outputs.public_zone_id
}

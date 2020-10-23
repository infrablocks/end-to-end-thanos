terraform {
  required_providers {
    aws      = {
      source  = "hashicorp/aws"
      version = "~> 3.12"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    null     = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = var.region
  version = "~> 3.2"
}

provider "null" {
  version = "~> 3.0"
}

provider "template" {
  version = "~> 2.2"
}
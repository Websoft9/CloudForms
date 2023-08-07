terraform {
  required_providers {
    alicloud = {
      version = "1.208.1"
    }

    template = {
      version = "2.2.0"
    }

    local = {
      version = "2.4.0"
    }
  }
}

provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
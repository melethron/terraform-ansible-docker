terraform {
  required_providers {
    vcd = {
      source  = "terraform-providers/vcd"
      version = "~> 2.9.0"
    }
    template  = {
      source  = "hashicorp/template"
      version = "~> 2.1.2"
    }
    local     = {
      version = "~> 1.4.0"
    }
    null      = {
      version = "~> 2.1.2"
    }
  }
  required_version = ">= 0.13"
}
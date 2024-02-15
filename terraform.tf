terraform {
  backend "remote" {
    # hostname = "app.terraform.io"
    organization = "fiap-lanches-eks"
    token = "2HfPkfLLKnB7LA.atlasv1.LOi9syR3Xz1WieOjIxnnPn2UXH4QaxvAHfEy4V8YzLdnMONsrQSNYzhvygwZsiaurzM"

    workspaces {
      name = "fiap-lanches-workflow"
    }
  }

  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "~> 0.52.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
  }

    required_version = ">= 1.3"
}

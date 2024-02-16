# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# data "aws_eks_cluster" "cluster" {
#   name = "fiap-lanches-eks-cWTzWOQb"
# }

provider "helm" {
  kubernetes {
    host                   = "fiap-lanches-eks-cWTzWOQb".endpoint
    cluster_ca_certificate = base64decode("fiap-lanches-eks-cWTzWOQb".certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "fiap-lanches-eks-cWTzWOQb"]
      command     = "aws"
    }
  }
}

resource "helm_release" "fiap-lanches" {
  name = "fiap-lanches"

  chart = "https://github.com/jonathansantoss/fiap-lanches-helm/releases/download/fiap-lanches-0.2.0/fiap-lanches-0.2.0.tgz"
}

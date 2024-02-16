# # Copyright (c) HashiCorp, Inc.
# # SPDX-License-Identifier: MPL-2.0


provider "helm" {
  kubernetes {
    # host                   = data.aws_eks_cluster.cluster.endpoint
    host                   = module.eks.cluster_endpoint
    # cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "fiap-lanches-eks-cWTzWOQb"]
      command     = "aws"
    }
  }
}

resource "helm_release" "fiap-lanches" {
  name = "fiap-lanches"
  chart = "https://github.com/jonathansantoss/fiap-lanches-helm/tree/gh-pages/fiap-lanches"
  namespace = "fiap-lanches"
  create_namespace = true
  force_update = true
  wait = false
  lint = true
  recreate_pods = true

   set {
    name  = "service.type"
    value = "LoadBalancer"
  }
    set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }
}

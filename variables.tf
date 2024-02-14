resource "random_string" "suffix" {
  length  = 8
  special = false
}

variable "cluster_name" {
  type = string
  default = "fiap-lanches-eks-${random_string.suffix.result}"
}

variable "cluster_name" {
  type = string
  default = "fiap-lanches-eks-${random_string.suffix.result}"
}

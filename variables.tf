variable "cluster-name" {
  type = string
  default = "fiap-lanches-eks-${random_string.suffix.result}"
}

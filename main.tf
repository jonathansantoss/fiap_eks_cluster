provider "aws" {
  region = "us-east-1"
}


data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "terraform_remote_state" "eks" {
  backend = "remote"
    config = {
      organization = "fiap-lanches-eks"

    workspaces = {
      name = "fiap-lanches-workflow"
    }
  }
}

# data "aws_eks_cluster" "cluster" {
#   name = "fiap-lanches-eks-cWTzWOQb"
# }

data "aws_eks_cluster_auth" "cluster" {
  name = "fiap-lanches-eks-cWTzWOQb"
}

locals {
  cluster_name = "fiap-lanches-eks-cWTzWOQb"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "fiap-lanches-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

module "helm_release" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

  name = "echo"

  eks_cluster_oidc_issuer_url = "https://"

  chart = "https://github.com/jonathansantoss/fiap-lanches-helm/releases/download/fiap-lanches-0.2.0/fiap-lanches-0.2.0.tgz"
  chart_version = "0.2.0"

  create_namespace     = true
  kubernetes_namespace = "echo"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 300
  wait            = true

  # These values will be deep merged
  # values = [
  # ]

  # Enable the IAM role
  iam_role_enabled = true

  # Add the IAM role using set()
  service_account_role_arn_annotation_enabled = true

  # Dictates which ServiceAccounts are allowed to assume the IAM Role.
  # In this case, only the "echo" ServiceAccount in the "echo" namespace
  # will be able to assume the IAM Role created by this module.
  service_account_name      = "echo"
  service_account_namespace = "echo"

  # IAM policy statements to add to the IAM role
  iam_policy = [{
    statements = [{
      sid        = "ListMyBucket"
      effect     = "Allow"
      actions    = ["s3:ListBucket"]
      resources  = ["arn:aws:s3:::test"]
      conditions = []
    },
    {
      sid        = "WriteMyBucket"
      effect     = "Allow"
      actions    = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
      resources  = ["arn:aws:s3:::test/*"]
      conditions = []
    }]
  }]
}
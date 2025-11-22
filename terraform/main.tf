provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.namespace
      Terraform = "true"
    }
  }
}

provider aws {
  alias  = "us"
  region = "us-east-1"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["--region", var.region, "eks", "get-token", "--cluster-name", module.eks.cluster_name, "--output", "json"]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["--region", var.region, "eks", "get-token", "--cluster-name", module.eks.cluster_name, "--output", "json"]
    command     = "aws"
  }
}



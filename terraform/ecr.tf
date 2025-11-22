module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  version = "~> 3.1"

  providers = {
    aws = aws.us
  }

  repository_name = "${var.namespace}-sender"
  repository_type = "public"

  public_repository_catalog_data = {
    description       = "Docker container for running Consensys Sender"
    operating_systems = ["Linux"]
    architectures     = ["x86"]
  }
}
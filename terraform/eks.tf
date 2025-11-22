module "aws_ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.4"

  name = "aws-ebs-csi"

  attach_aws_ebs_csi_policy = true
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"

  depends_on = [module.aws_ebs_csi_pod_identity]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.namespace
  kubernetes_version = "1.34"

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      pod_identity_association = [{
        role_arn        = module.aws_ebs_csi_pod_identity.iam_role_arn
        service_account = "ebs-csi-controller-sa",
      }]
    }
    snapshot-controller = {}
    kube-proxy     = {}
    metrics-server = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    "${var.namespace}-eks-compute" = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]

      min_size = 2
      max_size = 3
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }

  enable_irsa = true

  endpoint_public_access = true

  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::025857592400:user/Me"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
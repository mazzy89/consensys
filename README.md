# Consensys Linea Stack

A comprehensive infrastructure and deployment repository for the Consensys Linea project.

## Repository Structure

### Deploy Directory

The `deploy` directory contains manifests used for application deployment.
This includes:

- Kustomize manifest to define the Gateway API
- Helm chart values
- Helm chart encrypted secrets

Files in this directory are referenced in the [helmfile.yaml.gotmpl](./helmfile.yaml.gotmpl) to deploy the Linea stack.

### Helm Directory

The `helm` directory contains the Kubernetes `Linea` Helm chart for deploying the application components:
- `maru`
- `sequencer`
- `besu`
- `ethstats`
- `sender` (optional)

It is released publicly using the Make target `helm-push` and available at `oci://public.ecr.aws/j0t0w2r4/linea`

For detailed information about the Helm chart configuration and values, please refer to
the [Linea Helm Chart README](./helm/linea/README.md).

### Terraform Directory

The `terraform` directory contains Infrastructure as Code (IaC) configurations:

- AWS VPC
- AWS EKS
- Kubernetes Addons
- AWS public ECR

### Go Application

The Consensys Sender app is a Go application built with minimal dependencies.
The Docker image can be built and pushed to a public ECR repository using the provided [Makefile](./Makefile).

## Build and Deployment

### Prerequisites

All the required tools and dependencies can be installed automatically using Nix package manager with Flakes enabled:

1. Install Nix package manager following the instructions at https://nixos.org/download.html
2. Enable Flakes by adding the following to your `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```
3. Install
   - `direnv`
   - [`nix-direnv`](https://github.com/nix-community/nix-direnv)
   
This will ensure that once you get access to the repository Nix environment is automatically enabled.

### Terraform

To deploy infrastructure using Terraform:

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform and download required providers:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the infrastructure changes:
   ```bash
   terraform apply
   ```

Note: Make sure you have:

- Valid AWS credentials configured (For this experiment the `AWS_PROFILE` is set into `.envrc` so it is automatically set)
- Appropriate permissions to create/update/delete resources

The Terraform workspace will create the EKS cluster named `consensys` with the required addons installed.

### Helmfile

The Helm chart lifecycle is managed using [Helmfile](https://github.com/helmfile/helmfile)
It allows you to declaratively define the specifications of all the charts intended to be released.

To run successfully, Helmfile, run first:

- `make docker-build`
- `make docker-push`
- `make helm-push`

Then

`make helmfile-apply`

#### Secrets

Applications secrets are stored encrypted using [Sops](https://github.com/getsops/sops) and AWS KMS.
They are decrypted at release time and stored in Kubernetes secrets within the cluster.

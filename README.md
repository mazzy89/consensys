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

### Terraform Directory

The `terraform` directory contains Infrastructure as Code (IaC) configurations:

- AWS VPC
- AWS EKS
- Kubernetes Addons

## Build and Deployment

### Prerequisites

All the required tools and dependencies can be installed automatically using Nix package manager with Flakes enabled:

1. Install Nix package manager following the instructions at https://nixos.org/download.html
2. Enable Flakes by adding the following to your `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```
3. Run `nix develop` in the project root directory to enter a shell with all required tools installed:
    - Docker
    - Helm
    - Terraform
    - kubectl
    - Other development dependencies

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

- Valid AWS credentials configured
- Appropriate permissions to create resources

The Terraform workspace will run an EKS cluster named `consensys` with the required addons installed

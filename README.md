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
The Docker image can be built locally and pushed to the public ECR repository using the provided [Makefile](./Makefile).

#### Send Tx

The application uses Legacy transaction type following the upstream [example](https://github.com/ethereum/go-ethereum/blob/master/ethclient/ethclient_test.go) for sending transactions instead of EIP-1559 (Type 2) transactions. This
decision was made because:

- No explicit requirements were specified for the transaction type
- Legacy transactions provide better compatibility across different Ethereum networks
- They are simpler to implement and test
- The gas pricing mechanism is more predictable

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

- An active AWS account
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

Application secrets in Helm are stored encrypted using [Sops](https://github.com/getsops/sops) and pre-generated AWS KMS.
They are decrypted at release time and stored in Kubernetes secrets within the cluster.

## Further improvements

### TLS Certificates

The current implementation does not include TLS certificate management as there were no explicit requirements for it.
However, for production-ready applications, Besu node endpoints must have TLS certificates configured.

The recommended solution would be to:

- Deploy `cert-manager` in the cluster for automated certificate management
- Use DNS validation for certificate issuance
- Configure TLS certificates through annotations at the Gateway API Gateway level

This would ensure secure HTTPS communication for all Besu node endpoints while maintaining automated certificate
lifecycle management.

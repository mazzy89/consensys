  {
    description = "Development environment for Consensys";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    outputs = { self, nixpkgs }: let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: rec {
            kubernetes-helm-wrapped = prev.wrapHelm prev.kubernetes-helm {
              plugins = with prev.kubernetes-helmPlugins; [
                helm-diff
                helm-secrets
              ];
            };
          })
        ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.awscli2
          pkgs.docker
          pkgs.kubernetes-helm-wrapped
          pkgs.kustomize
          pkgs.helmfile-wrapped
          pkgs.pre-commit
          pkgs.go
          pkgs.jq
          pkgs.k9s
          pkgs.kubectl
          pkgs.kubecolor
          pkgs.kubie
          pkgs.terraform
          pkgs.helm-docs
          pkgs.sops
        ];

      shellHook =
      ''
        echo "Welcome to your Consensys Nix dev shell!"
      '';
      };
    };
  }
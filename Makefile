.PHONY: test build push helmfile-diff helmfile-apply helm-docs

IMAGE_HELM_UNITTEST=docker.io/helmunittest/helm-unittest:3.17.2-0.8.0

IMAGE_CONSENSYS_SENDER=public.ecr.aws/j0t0w2r4/consensys-sender
IMAGE_TAG_CONSENSYS_SENDER := $(shell git rev-parse --short HEAD)
IMAGE_ARCH_CONSENSYS_SENDER=linux/amd64

build:
	docker build --platform $(IMAGE_ARCH_CONSENSYS_SENDER) -t $(IMAGE_CONSENSYS_SENDER):$(IMAGE_TAG_CONSENSYS_SENDER) $(CURDIR)

push:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
	docker push $(IMAGE_CONSENSYS_SENDER):$(IMAGE_TAG_CONSENSYS_SENDER)

helmfile-diff:
	helmfile diff -f helmfile.yaml.gotmpl

helmfile-apply:
	helmfile apply -f helmfile.yaml.gotmpl

helm-test:
	docker run --entrypoint /bin/sh --rm -v $(CURDIR):/charts -w /charts $(IMAGE_HELM_UNITTEST) /charts/hack/test.sh

helm-docs:
	helm-docs --chart-search-root $(CURDIR)/helm/linea --skip-version-footer

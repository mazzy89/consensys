.PHONY: test build push helmfile-apply

IMAGE_HELM_UNITTEST=docker.io/helmunittest/helm-unittest:3.17.2-0.8.0

IMAGE_CONSENSYS_SENDER=public.ecr.aws/j0t0w2r4/consensys-sender
IMAGE_TAG_CONSENSYS_SENDER := $(shell git rev-parse --short HEAD)
IMAGE_ARCH_CONSENSYS_SENDER=linux/amd64

test:
	docker run --entrypoint /bin/sh --rm -v $(CURDIR):/charts -w /charts $(IMAGE_HELM_UNITTEST) /charts/hack/test.sh
	
build:
	docker build --platform $(IMAGE_ARCH_CONSENSYS_SENDER) -t $(IMAGE_CONSENSYS_SENDER):$(IMAGE_TAG_CONSENSYS_SENDER)

push:
	docker push $(IMAGE_CONSENSYS_SENDER):$(IMAGE_TAG_CONSENSYS_SENDER)

helmfile-apply:
	helmfile apply -f helmfile.yaml.gotmpl


DOCKERFILE=Dockerfile
DOCKERFILE_TEMPLATE=Dockerfile.template
IMAGE_URL=quay.io/everydayhero/buildkite:latest

default:
	@echo "Generating Dockerfile"
	@perl -X -p -i -e 's/\$$\{([^}]+)\}/defined $$ENV{$$1} ? $$ENV{$$1} : $$&/eg' > $(DOCKERFILE) < $(DOCKERFILE_TEMPLATE)

Dockerfile: default

build: Dockerfile
	docker build -t $(IMAGE_URL) .

push: build
	docker push $(IMAGE_URL)

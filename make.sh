IMAGE_URL=quay.io/everydayhero/buildkite
tag=${TAG:-"latest"}

bin/generate Dockerfile.template Dockerfile
docker build -t $IMAGE_URL:$tag .
docker push $IMAGE_URL:$tag

IMAGE_URL=quay.io/everydayhero/buildkite
TAG=${$TAG:-latest}

bin/download id_rsa
bin/generate Dockerfile.template Dockerfile
docker build -t $IMAGE_URL:$TAG .
docker push $IMAGE_URL:$TAG

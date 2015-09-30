## buildkite-docker

[![Build status](https://badge.buildkite.com/54481cb75a0ad687169b2bd3cc2ef0ad6c88c78f3518c2d90d.svg)](https://buildkite.com/everyday-hero/buildkite-agent)

This is the buildkite agent container which utilises Docker in Docker. There are no environment variables needed to pass in as they are all 
baked into the container.

## Building the container
Because there is a heap of things built in there is a Dockerfile.template that needs to be used with `make.sh` to generate the Dockerfile.

Take a look at `.buildkite/pipeline.yml` to see how to build this locally.

## Running the agent in as a unit

```
[Unit]
Description=Buildkite agent
After=agent-setup.service
Requires=agent-setup.service

[Service]
User=core
Environment="IMAGE_URL=quay.io/everydayhero/buildkite"
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker rm -f buildkite-agent-1
ExecStartPre=/usr/bin/docker pull ${IMAGE_URL}
ExecStart=/usr/bin/docker run \
  --name buildkite-agent-1 \
  -v /home/core/.ssh/buildkite-agent-1:/root/.ssh/controlmasters \
  --privileged \
  ${IMAGE_URL}
ExecStop=/usr/bin/docker kill buildkite-agent-1
RestartSec=30s
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

The line:

`/home/core/.ssh/buildkite-agent-1:/root/.ssh/controlmasters`

is implemented because controlmasters can't use an overlay file system which is the default inside the container so we mount in a directory from the host to ensure we get an ext4 fs.

## Using Artifacts
This allows passing of artifacts between pipeline steps as each step is independant of each other. The atifact is uploaded and downloaded to an s3 bucket located at [edh-buildkite-artifacts.s3-website-us-east-1.amazonaws.com](edh-buildkite-artifacts.s3-website-us-east-1.amazonaws.com). The keys to access this are baked into the container at build time

Do something like this to update:

`<command that outpus .plan file> && buildkite-agent artifact upload '*.plan'`

When you want to get access to an artifact and use it, do this:

`buildkite-agent artifact download --debug '*.plan' . && <command>`


Official documentation here [https://buildkite.com/docs/guides/artifacts](https://buildkite.com/docs/guides/artifacts)

## Rolling vlad the deployer keys

What makes most things work is the private key for vlad the deployer has been baked into the container. This means there are a couple of steps if a new key is generated.

The private key is located at [edh-buildkite-artifacts.s3-website-us-east-1.amazonaws.com/buildkite-secrets](edh-buildkite-artifacts.s3-website-us-east-1.amazonaws.com/buildkite-secrets), the id_rsa file in this directory needs to be replaced with the new one.

You then need to add the new key to the deployer github account, email for that account is deployer@everydayhero.com (which gets sent to edh-dev@everydayhero.com.au if a reset the password is needed).

Once that is done trigger a `New Build` or just rebuild the latest MASTER build and deploy via the pipeline ([https://buildkite.com/everyday-hero/buildkite-agent](https://buildkite.com/everyday-hero/buildkite-agent)).


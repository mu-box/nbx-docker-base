#!/bin/bash -e

# Build base image
docker build -t nanobox/nbx-base -f Dockerfile .

# Build core stack images (Leave the for loop in case we add others after all.)
for stack in data
do
	docker build -t nanobox/nbx-${stack} -f Dockerfile.${stack} .
done

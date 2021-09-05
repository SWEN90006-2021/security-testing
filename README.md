# SWEN90006: Security & Software Testing

This repository contains instructions to run examples in lectures 7-12. We use Docker that allows students to build and run examples in the same way regardless of their operating systems (e.g., Linux, Windows, or macOS).

# Installation

## Install Docker

Please follow [this instruction](https://docs.docker.com/get-docker/) to install Docker on your machine.

## Build a Docker image

First, we need to build a Docker image using the given Dockerfile. The Docker image has everything ready for our experiments. Once we make changes to the Dockerfile, we would need to rerun this command.
```bash
docker build . -t swen90006 --no-cache
```

If the build is successful, we should have a new Docker image named swen90006. To see all Docker images on our computer, we can run the following command.
```bash
docker image ls
```

# Weekly Examples

Before start running an example, we need to start a Docker container using the successfully built Docker image
```bash
docker run -it swen90006 /bin/bash
```

## Week 7: Introduction to Security Testing

Run the random fuzzer to fuzz the check_pin example
```bash
cd $WORKDIR
./random_fuzzer.sh ./check_pin 20 results
```

Run the mutation-based fuzzer to fuzz the check_pin example
```bash
cd $WORKDIR
./mutation_fuzzer.sh ./check_pin 1234 20 results
```

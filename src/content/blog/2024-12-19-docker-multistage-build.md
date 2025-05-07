---
title:  "Docker multistage build"
description: ""
pubDate:   2024-12-19 11:27:00 +0100
categories: Docker
slug: docker/2024/12/19/multistage-build.html
heroImage: "/docker.svg"
---

This gives some examples on how to use docker multistage builds with a NodeJS bases image.

## Overview of files

## Base image docker file

It's a good idea to create two base images, one for building and testing the application and another smaller image for running the application.

This insures you have some control of the software in the base images and also you don't have to wait for all the steps in these images in your application builds.

There is a good example here of how to do that also support multi arch builds: https://github.com/connectedcars/docker-node/blob/master/Dockerfile

## Application docker file

``` dockerfile
ARG NODE_VERSION=20.x
ARG COMMIT_SHA

FROM node-builder/master:$NODE_VERSION as builder

ARG NPM_TOKEN
ARG COMMIT_SHA=master

RUN echo ${COMMIT_SHA}

# Install tools needed for running build and tests
RUN apt-get update -qq && \
	apt-get install -qq -y --no-install-recommends zstd && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app

USER builder

# Copy application code.
COPY --chown=builder:builder . /app

RUN npm ci

# Run ci checks
RUN npm run test

RUN npm run build

# Continue build
FROM node-base/master:$NODE_VERSION

ARG COMMIT_SHA

USER nobody

ENV NODE_ENV production

WORKDIR /app

COPY --from=builder /app .

ENV COMMIT_SHA=$COMMIT_SHA

RUN echo ${COMMIT_SHA}

CMD ["node", "build/dist/src/start.js"]
```
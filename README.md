# Docker containers with Python

## Introduction

This repository contains Docker images with different versions of Python installed. All are based on the 
`[consul-template-base](https://hub.docker.com/r/metabrainz/consul-template-base/)`, which comes with
[Consul Template](https://github.com/hashicorp/consul-template) and other tools like *runit* installed.

### Consul Template

Consul Template runs as a separate service managed by *runit*, and is **turned on by default**. If you don't
need to use Consul Template, that service needs to be removed explicitly in the Dockerfile that you are
writing.

Configuration for it must be stored in the */etc/consul-template.conf* file. See its
[documentation](ttps://github.com/hashicorp/consul-template) for setup details.

## Usage

To use these images simply specify `FROM metabrainz/python:<TAG>` at the beginning of your Dockerfile.
`<TAG>` is a version of Python that you need to use. List of available tags is at https://hub.docker.com/r/metabrainz/python/tags/.

## Building and deploying images

Example:

    $ cd 3.5
    $ docker build -t metabrainz/python:3.5 .; docker push metabrainz/python:3.5

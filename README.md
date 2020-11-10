# Docker images with Python

## Introduction

This repository contains Docker images with different versions of Python installed. All are based on the 
[`consul-template-base`](https://hub.docker.com/r/metabrainz/consul-template-base/) image, which comes with
[Consul Template](https://github.com/hashicorp/consul-template) and other tools like *runit* installed.

### Consul Template

Consul Template runs as a separate service managed by *runit*, and is **turned on by default**. If you don't
need to use Consul Template, that service needs to be removed explicitly in the Dockerfile that you are
writing.

Configuration for it must be stored in the */etc/consul-template.conf* file. See its
[documentation](https://github.com/hashicorp/consul-template) for setup details.

## Usage

To use these images simply specify `FROM metabrainz/python:<TAG>` at the beginning of your Dockerfile.
`<TAG>` is a *version of Python* that you need to use, followed with the *creation date* of the image;
If an image is updated more than once in a day, then extra tags will also include the sequence number.
See the [list of image tags available on Docker Hub|https://hub.docker.com/r/metabrainz/python/tags/].

## Building and deploying images

Use [`push.sh`](push.sh) script.  The way it operates is detailed in its heading comments.

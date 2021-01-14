# Docker images with Python

## Introduction

This repository contains Docker images with different versions of Python installed. All are based on the 
[`consul-template-base`](https://hub.docker.com/r/metabrainz/consul-template-base/) image, which comes with
[Consul Template](https://github.com/hashicorp/consul-template) and other tools like *runit* installed.

### Consul Template

Consul Template runs as a separate service managed by *runit*.

With Consul Template 0.16, Configuration for it must be stored in the */etc/consul-template.conf* file. See its
[documentation](https://github.com/hashicorp/consul-template) for setup details.
Consul Template is **turned on by default**. If you don't
need to use Consul Template, that service needs to be removed explicitly in the Dockerfile that you are
writing.

With Consul Template 0.18, you must create your own runit service and use the `run-consul-template`
script to render a template and execute a child process. See an 
[example in the MusicBrainz server](https://github.com/metabrainz/musicbrainz-server/tree/master/docker/musicbrainz-website).

## Usage

To use these images simply specify `FROM metabrainz/python:<TAG>` at the beginning of your Dockerfile.
`<TAG>` is a *version of Python* that you need to use, followed with the *creation date* of the image;
If an image is updated more than once in a day, then extra tags will also include the sequence number.
See the [list of image tags available on Docker Hub|https://hub.docker.com/r/metabrainz/python/tags/].

## Building and deploying images

Use [`push.sh`](push.sh) script.  The way it operates is detailed in its heading comments.

## Available images

We have these images available:

image version | python version | consul-template version
----|----|----
2.7, 2.7-20201201 | 2.7.18 | 0.16
3.6-1 | 3.6.8 | 0.18
3.6, 3.6-20201201 | 3.6.12 | 0.16
3.7, 3.7-20201201 | 3.7.9 | 0.16
3.8, 3.8-20201201 | 3.8.6 | 0.16
3.9, 3.9-20210115 | 3.9.1 | 0.18
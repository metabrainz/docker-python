#!/bin/bash
#
# Build all Python images image from the currently checked out version and
# push them it to the Docker Hub.

set -e -o pipefail -u

DOCKER_CMD=${DOCKER_CMD:-docker}

for version in 2.7 3.6 3.7 3.8
do
	pushd "$(dirname "${BASH_SOURCE[0]}")/${version}/"
	echo "Building ${version}..."
	${DOCKER_CMD} build -t metabrainz/python:${version} .
	echo "Pushing ${version}..."
	${DOCKER_CMD} push metabrainz/python:${version}
	popd
done

echo "Done!"

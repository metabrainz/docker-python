#!/usr/bin/env bash
#
# Build all Python images image from the currently checked out version and
# push them it to the Docker Hub.

set -e -o pipefail -u

image_name='metabrainz/python'

DOCKER_CMD=${DOCKER_CMD:-docker}

for version in 2.7 3.6 3.7 3.8
do
	pushd "$(dirname "${BASH_SOURCE[0]}")/${version}/"
	echo "Building ${version}..."
	${DOCKER_CMD} build -t ${image_name}:${version} .
	echo "Pushing ${version}..."
	${DOCKER_CMD} push ${image_name}:${version}
	popd
done

echo "Done!"

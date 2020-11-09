#!/bin/bash
#
# Build all Python images image from the currently checked out version and
# push them it to the Docker Hub.

set -e -o pipefail -u

for version in 2.7 3.6 3.7 3.8
do
	pushd "$(dirname "${BASH_SOURCE[0]}")/${version}/"
	echo "Building ${version}..."
	docker build -t metabrainz/python:${version} .
	echo "Pushing ${version}..."
	docker push metabrainz/python:${version}
	popd
done

echo "Done!"

#!/bin/bash
#
# Build all Python images image from the currently checked out version and
# push them it to the Docker Hub.

for version in 2.7 3.5 3.6
do
	pushd "$(dirname "${BASH_SOURCE[0]}")/${version}/"
	echo "Building ${version}..."
	docker build -t metabrainz/python:${version}-1 .
	echo "Pushing ${version}..."
	docker push metabrainz/python:${version}-1
	popd
done

echo "Done!"

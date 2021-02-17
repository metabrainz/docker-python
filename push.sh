#!/usr/bin/env bash
#
# Build Docker images for each Python version `x.y`;
# Tag them `x.y` and `x.y-date`;
# Add `x.y-date.sequence` tags if built more than once in a day;
# Finally, push them to Docker Hub.
#
# This script is purposed for maintainers only, not contributors.
#
# Usage:
#   $ ./push.sh

set -e -o pipefail -u

image_name='metabrainz/python'

DOCKER_CMD=${DOCKER_CMD:-docker}

for cmd in grep jq sed wget
do
	if ! type "${cmd}" &>/dev/null
	then
		echo >&2 "Error: ${cmd}: command not found"
		exit 69 # EX_UNAVAILABLE
	fi
done

# shellcheck disable=SC2207
remote_tags=($(wget -q \
	https://registry.hub.docker.com/v1/repositories/${image_name}/tags \
	-O - | jq -r '.[] | .name'))

for version in 2.7 3.7 3.8 3.9
do
	pushd "$(dirname "${BASH_SOURCE[0]}")/${version}/"
	echo "Building ${version}..."
	${DOCKER_CMD} build -t ${image_name}:${version} .
	created=$(${DOCKER_CMD} inspect -f '{{.Created}}' ${image_name}:${version} \
		| sed 's/^\(....\)-\(..\)-\(..\)T.*$/\1\2\3/')
	date_version=${version}-${created}
	if [[ " ${remote_tags[*]} " == *" ${date_version} "* ]]
	then
		tags_count=$(printf '%s\n' "${remote_tags[@]}" | grep -c -F "${date_version}")
		if [[ ${tags_count} -eq 1 ]]
		then
			backup_version=${date_version}.0
			echo "Backing up previous ${date_version} as ${backup_version}..."
			if [[ " ${remote_tags[*]} " == *" ${backup_version} "* ]]
			then
				echo >&2 "Error: Backup tag ${backup_version} already exists"
				exit 70 # EX_SOFTWARE
			fi
			${DOCKER_CMD} pull "${image_name}:${date_version}"
			${DOCKER_CMD} tag "${image_name}:${date_version}" "${image_name}:${backup_version}"
			${DOCKER_CMD} push "${image_name}:${backup_version}"
			remote_tags+=("${backup_version}")
		fi
		sequence=$(printf '%s\n' "${remote_tags[@]}" | grep -c -F "${date_version}.")
		sequence_version=${version}-${created}.${sequence}
		if [[ " ${remote_tags[*]} " == *" ${sequence_version} "* ]]
		then
			echo >&2 "Error: Sequence tag ${sequence_version} already exists"
			exit 70 # EX_SOFTWARE
		fi
		${DOCKER_CMD} tag "${image_name}:${version}" "${image_name}:${sequence_version}"
		echo "Pushing ${sequence_version}..."
		${DOCKER_CMD} push "${image_name}:${sequence_version}"
	fi
	${DOCKER_CMD} tag "${image_name}:${version}" "${image_name}:${date_version}"
	echo "Pushing ${date_version}..."
	${DOCKER_CMD} push "${image_name}:${date_version}"
	echo "Pushing ${version}..."
	${DOCKER_CMD} push ${image_name}:${version}
	popd
done

echo "Done!"

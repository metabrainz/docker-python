#!/usr/bin/env bash
#
# Build Docker images for each Python version `x.y` and push them as `x.y`;
# Then also tag them `x.y-date` on Docker Hub;
# Add `x.y-date.sequence` tags if built more than once in a day;
#
# This script is purposed for maintainers only, not contributors.
#
# Usage:
#   $ ./push.sh

set -e -o pipefail -u

image_name='metabrainz/python'

cd "$(dirname "${BASH_SOURCE[0]}")/"

DOCKER_CMD=${DOCKER_CMD:-docker}

for cmd in grep jq wget
do
	if ! type "${cmd}" &>/dev/null
	then
		echo >&2 "Error: ${cmd}: command not found"
		exit 69 # EX_UNAVAILABLE
	fi
done

# shellcheck disable=SC2207
remote_tags=($(wget -q \
	https://registry.hub.docker.com/v2/repositories/${image_name}/tags?page_size=100 \
	-O - | jq -r '.results[] | .name'))

for version in 3.11 3.12 3.13 3.14
do
	./build.sh --push "${version}"
	# Images are multi-platform, so `imagetools inspect` has one image config
	# per platform; read the linux/amd64 one.
	created=$(${DOCKER_CMD} buildx imagetools inspect \
		--format '{{(index .Image "linux/amd64").Created.Format "20060102"}}' \
		"${image_name}:${version}")
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
			${DOCKER_CMD} buildx imagetools create \
				--tag "${image_name}:${backup_version}" \
				"${image_name}:${date_version}"
			remote_tags+=("${backup_version}")
		fi
		sequence=$(printf '%s\n' "${remote_tags[@]}" | grep -c -F "${date_version}.")
		sequence_version=${version}-${created}.${sequence}
		if [[ " ${remote_tags[*]} " == *" ${sequence_version} "* ]]
		then
			echo >&2 "Error: Sequence tag ${sequence_version} already exists"
			exit 70 # EX_SOFTWARE
		fi
		echo "Tagging ${version} as ${sequence_version} on Docker Hub..."
		${DOCKER_CMD} buildx imagetools create \
			--tag "${image_name}:${sequence_version}" \
			"${image_name}:${version}"
	fi
	echo "Tagging ${version} as ${date_version} on Docker Hub..."
	${DOCKER_CMD} buildx imagetools create \
		--tag "${image_name}:${date_version}" \
		"${image_name}:${version}"
done

echo "Done!"

#!/usr/bin/env bash
#
# Build Docker image for a specific Python version.
#
# This script is purposed for contributors.
#
# It is also called from `push.sh` which is for maintainers only.
#
# Usage:
#   $ ./build.sh 3.14

set -e -o pipefail -u

SCRIPT_NAME=$(basename "$0")
HELP=$(cat <<EOH
Usage: $SCRIPT_NAME [--help|--amd-only|--local-platform|--push] <python-version>

Options:
  --help                Print this help message

  --amd-only            Build image for linux/amd64 only.
                        This is only for older Python versions whose
                        Dockerfile uses a metabrainz/consul-template-base
                        tag that is not available for linux/arm64.

  --local-platform      Build image to run on the host platform only.
                        This is intended for local development and testing,
                        to skip building images for unnecessary targets.

                        Do not use it to build image for a public repository.

  --push                Push the built image to Docker Hub.
                        Without it, the image is added to your local Docker
                        images, so it can be run with \`docker run\`.
                        This is used by push.sh, for maintainers only.
                        It cannot be combined with --local-platform.

  Notes:
    For multi-platform builds, there are some prerequisites to the host; see:
    https://docs.docker.com/build/building/multi-platform/
EOH
)

# Set default platform to build
platform_option='--platform linux/arm64,linux/amd64'
local_platform=false
output_option='--load'
version=''

for arg in "$@"
do
  case $arg in
    "--amd-only")
      platform_option='--platform linux/amd64'
      ;;
    "--help")
      echo "$HELP"
      exit 0 # EX_OK
      ;;
    "--local-platform")
      platform_option=''
      local_platform=true
      ;;
    "--push")
      output_option='--push'
      ;;
    -*)
      echo >&2 "$SCRIPT_NAME: unknown option: '$arg'"
      echo >&2 "Try '$SCRIPT_NAME --help' for usage."
      exit 64 # EX_USAGE
      ;;
    *)
      if [[ -n $version ]]
      then
        echo >&2 "$SCRIPT_NAME: too many arguments"
        echo >&2 "Try '$SCRIPT_NAME --help' for usage."
        exit 64 # EX_USAGE
      fi
      version="$arg"
      ;;
  esac
done

cd "$(dirname "${BASH_SOURCE[0]}")/"

if [[ $local_platform == true && $output_option == '--push' ]]
then
  echo >&2 "$SCRIPT_NAME: --local-platform cannot be used with --push"
  echo >&2 "Try '$SCRIPT_NAME --help' for usage."
  exit 64 # EX_USAGE
fi

if [[ -z $version ]]
then
  echo >&2 "$SCRIPT_NAME: missing python version"
  echo >&2 "Try '$SCRIPT_NAME --help' for usage."
  exit 64 # EX_USAGE
elif [[ ! -f $version/Dockerfile ]]
then
  echo >&2 "$SCRIPT_NAME: invalid python version: '$version'"
  echo >&2 "Try '$SCRIPT_NAME --help' for usage."
  exit 64 # EX_USAGE
fi

image_name='metabrainz/python'

DOCKER_CMD=${DOCKER_CMD:-docker}

cd "${version}/"
if [[ $output_option == '--push' ]]
then
  echo "Building and pushing ${version} to Docker Hub..."
else
  echo "Building ${version}..."
fi
${DOCKER_CMD} buildx build ${platform_option} ${output_option} -t ${image_name}:${version} .

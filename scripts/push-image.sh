#
# Build a Docker image.
#
# Environment variables:
#
#   DOCKER_REGISTRY - The hostname of your private Docker registry.
#   DOCKER_UN - User name for your Docker registry.
#   DOCKER_PW - Password for your Docker registry.
#   VERSION - The version number to tag the images with.
#
# Parameters:
#
#   1 - The path to the code for the image and the name of the image.
#
# Usage:
#
#       ./scripts/push-image.sh <image-name>
#
# Example command line usage:
#
#       ./scripts/push-image.sh service
#

set -u # or set -o nounset
: "$1"
: "$DOCKER_REGISTRY"
: "$VERSION"
: "$DOCKER_UN"
: "$DOCKER_PW"

export DIR=$1
docker login $DOCKER_REGISTRY --username $DOCKER_UN --password $DOCKER_PW
docker push $DOCKER_REGISTRY/$DIR:$VERSION

#
# Publishes a Docker image.
#
# Environment variables:
#
#   CONTAINER_REGISTRY - The hostname of your container registry.
#   REGISTRY_UN - User name for your container registry.
#   REGISTRY_PW - Password for your container registry.
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
: "$CONTAINER_REGISTRY"
: "$VERSION"
: "$REGISTRY_UN"
: "$REGISTRY_PW"

export DIR=$1
echo $REGISTRY_PW | docker login $CONTAINER_REGISTRY --username $REGISTRY_UN --password-stdin
docker push $CONTAINER_REGISTRY/$DIR:$VERSION

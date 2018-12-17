#
# Build a Docker image.
#
# Environment variables:
#
#   DOCKER_REGISTRY - The hostname of your private Docker registry.
#   VERSION - The version number to tag the images with.
#
# Parameters:
#
#   1 - The path to the code for the image and the name of the image.
#
# Usage:
#
#       ./scripts/build-image.sh <image-name>
#
# Example command line usage:
#
#       ./scripts/build-image.sh service
#

set -u # or set -o nounset
: "$1"
: "$DOCKER_REGISTRY"
: "$VERSION"

export DIR=$1
docker build -t $DOCKER_REGISTRY/$DIR:$VERSION --file ./$DIR/Dockerfile-prod ./$DIR

# TODO: Add your code here to run and test the image.
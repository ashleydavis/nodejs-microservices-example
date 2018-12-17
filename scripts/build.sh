# Run the entire build and provision process.

./scripts/build-image.sh service
./scripts/build-image.sh web
./scripts/push-image.sh service
./scripts/push-image.sh web
./scripts/provision-kubernetes.sh

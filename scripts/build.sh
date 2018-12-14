# Run the entire build and provision process.

#TODO: How do I get docker un and pw from output of the first script?!

./scripts/provision-docker-registry.sh
./scripts/build-image.sh service
./scripts/build-image.sh web
./scripts/push-image.sh service
./scripts/push-image.sh web
./scripts/provision-kubernetes.sh

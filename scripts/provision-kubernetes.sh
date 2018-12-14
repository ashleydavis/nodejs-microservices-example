# Provision a Kubernetes cluster to host our Docker containers.

set -u # or set -o nounset
: "$VERSION"

cd ./scripts/infrastructure/kubernetes
terraform init 
terraform apply -auto-approve -var "version=$VERSION" -var "client_id=$ARM_CLIENT_ID" -var "client_secret=$ARM_CLIENT_SECRET"

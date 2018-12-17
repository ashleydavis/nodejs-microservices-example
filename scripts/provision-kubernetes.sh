# Provision a Kubernetes cluster to host our Docker containers.

set -u # or set -o nounset
: "$TF_BACKEND_RES_GROUP"
: "$TF_BACKEND_STORAGE_ACC"
: "$TF_BACKEND_CONTAINER"
: "$TF_BACKEND_KEY"
: "$VERSION"
: "$ARM_CLIENT_ID"
: "$ARM_CLIENT_SECRET"

cd ./scripts/infrastructure/kubernetes
terraform init  -backend-config="resource_group_name=$TF_BACKEND_RES_GROUP" -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACC" -backend-config="container_name=$TF_BACKEND_CONTAINER" -backend-config="key=$TF_BACKEND_KEY"
terraform apply -auto-approve -var "version=$VERSION" -var "client_id=$ARM_CLIENT_ID" -var "client_secret=$ARM_CLIENT_SECRET"

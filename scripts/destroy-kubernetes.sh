#
# Provision a Kubernetes cluster to host the Coinstash microservices application.
#

set -u # or set -o nounset
: "$ENVIRONMENT"
: "$TF_BACKEND_RES_GROUP"
: "$TF_BACKEND_STORAGE_ACC"
: "$TF_BACKEND_CONTAINER"
: "$VERSION"
: "$ARM_CLIENT_ID"
: "$ARM_CLIENT_SECRET"

cd ./scripts/infrastructure/kubernetes
terraform init \
    -backend-config="resource_group_name=$TF_BACKEND_RES_GROUP" \
    -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACC" \
    -backend-config="container_name=$TF_BACKEND_CONTAINER" \
    -backend-config="key=$ENVIRONMENT"
terraform destroy -auto-approve \
    -var "environment=$ENVIRONMENT" \
    -var "buildno=$VERSION" \
    -var "client_id=$ARM_CLIENT_ID" \
    -var "client_secret=$ARM_CLIENT_SECRET"

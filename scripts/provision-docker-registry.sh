# Provision a private Docker registry to host our Docker images.

cd ./scripts/infrastructure/docker
terraform -v
terraform init 
terraform apply -auto-approve

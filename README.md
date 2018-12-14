# nodejs-microservices-example

Example of Node.js microservices setup using Docker, Docker-Compose, Kubernetes and Terraform.

Based on some of my previous examples:

- https://github.com/ashleydavis/docker-compose-nodejs-example
- https://github.com/ashleydavis/docker-compose-nodejs-with-typescript-example
- https://github.com/ashleydavis/nodejs-docker-build-for-bitbucket-pipelines
- https://github.com/ashleydavis/terraform-azure-example-for-bitbucket-pipelines

## Requirements

- Vagrant and Virtual Box must be installed. When you bring up the Vagrant VM it has Docker, Docker-Compose, Terraform and the Azure CLI installed and ready to go.
- To provision to the cloud you need an Azure account and a service principle setup for authentication (see below for a link to instructions on that).

## Important files

- bitbucket-pipelines.yml -> Script that builds this system in the cloud on push to a Bitbucket repo.
- docker-compose.yml -> Script that boots the whole system locally for development and testing.
- Vagrantfile - Boots an Ubuntu VM that can be used for development, testing and running the provisioning scripts.
- db-fixture/           -> Docker container configure to load a database fixture into the MongoDB database.
- scripts/              -> Scripts for building and provisioning the system.
    - infrastructure/   -> Terraform scripts to build the cloud infrastructure.
        - docker/       -> Terraform scripts to build a private Docker registry.
        - kubernetes/   -> Terraform scripts to build a Kubernetes cluster to host our Docker containers.
    - build.sh          -> Master build script. Runs all other scripts in this directory in sequence. Can build this system in the cloud from scratch.

## Starting the microservices application

### Using Vagrant for development

Have Vagrant and Virtual box installed.

Boot the VM:

    vagrant up

Shell into the VM:

    vagrant ssh

In the VM, run:

    cd /vagrant

    sudo docker-compose up

To build after you change code:

    sudo docker-compose up --build

Web page now available:

    http://127.0.0.1:7000/

API available:

    http://127.0.0.1:7100/data

Database available:

    mongodb://127.0.0.1:7200

In the dev environment updates to the code on the host OS automatically flow through to the microservices in the Docker containers which are rebooted automatically using nodemon.

### Using Docker / Docker-Compose for development

Have docker / docker compose installed.
Check vagrant-provision-vm.sh for example installation commands.

Run:

    docker-compose up

To build after you change code:

    docker-compose up --build

Web page now available:

    http://127.0.0.1:80/

API available:

    http://127.0.0.1:8080/data

Database available:

    mongodb://127.0.0.1:27017

In the dev environment updates to the code on the host OS automatically flow through to the microservices in the Docker containers which are rebooted automatically using nodemon.

### Provision the cloud system using Terraform

Please have Terraform and Azure CLI installed.
Check provision-dev-vm.sh for example installation commands.

#### Environment variables for provisioning

Environment variables must be set before running these scripts.

To provision this system in Azure you need the following environment variables set:
    - ARM_SUBSCRIPTION_ID
    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET 
    - ARM_TENANT_ID

For more details on these environment variables please see [the Terraform docs for the Azure provider]  (https://www.terraform.io/docs/providers/azurerm/index.html#argument-reference).

- For storing Terraform state in Azure storage set these environment variables:
    - TF_BACKEND_RES_GROUP
    - TF_BACKEND_STORAGE_ACC
    - TF_BACKEND_CONTAINER
    - TF_BACKEND_KEY

#### Run scripts to build, provision and deploy

Before running each script, please ensure it is flagged as executable, eg:

    chmod +x ./scripts/build-image.sh

Provision your Docker registry:

    ./scripts/provision-docker-registry.sh

Build the Docker images:

    ./scripts/build-image.sh service
    ./scripts/build-image.sh web

Push the Docker image to the Docker registry:

    ./scripts/push-image.sh service
    ./scripts/push-image.sh web

Now provision your Kubernetes cluster:

    ./scripts/provision-kubernetes.sh

TODO: Finally To deploy the microservices system:

    ./scripts/deploy.sh

This will build your images, push them to your docker registry and then use Terraform to establish the infrastructure.

Please see below for environment variables you must set to run the provisioning script.

TODO: build.sh

### Integration with Bitbucket Pipelines

This repo integrates with Bitbucket Pipelines for continuous integration / delivery.

If you put this repo in Bitbucket it will run the script in the file bitbucket-pipelines.yml on each push to the repository. This builds the Docker containers, copies the images to your private Docker Registry, provisions the environment on Azure and deploys the code.

Please see the next section that lists [the environment variables you must set in Bitbucket](https://confluence.atlassian.com/bitbucket/variables-in-pipelines-794502608.html)




## Testing

### Unit testing

Each service can be tested indepdently, but that's not included in this example.
You just need to install Jest (or other) then write some tests, then hook up the npm test script so you can run:

    npm test

### Integration testing

todo

### UI Testing

todo

## Resources

Creating a service principle:
https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html

https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html

Great video from Scott Hanselman
https://www.youtube.com/watch?v=iECZMWIQfgc
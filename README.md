# nodejs-microservices-example

Example of Node.js microservices setup using Docker, Docker-Compose, Kubernetes and Terraform.

Follow [the developer on Twitter](https://twitter.com/ashleydavis75) for updates. 

Need to build a microservices application? Learn how to do this with [Bootstrapping Microservices](http://bit.ly/2o0aDsP).

Need to do exploratory coding, data analysis and visualization in JavaScript/TypeScript? [Check out Data-Forge Notebook](http://www.data-forge-notebook.com/)

Based on some of my previous examples:

- https://github.com/ashleydavis/docker-compose-nodejs-example
- https://github.com/ashleydavis/docker-compose-nodejs-with-typescript-example
- https://github.com/ashleydavis/nodejs-docker-build-for-bitbucket-pipelines
- https://github.com/ashleydavis/terraform-azure-example-for-bitbucket-pipelines

## Requirements

- Vagrant and Virtual Box must be installed. When you bring up the Vagrant VM it has Docker, Docker-Compose, Terraform and the Azure CLI installed and ready to go.
- To provision on Azure create a service principle for authentication: [https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).
- You need an Azure storage account and container to store Terraform state: [https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks#set-up-azure-storage-to-store-terraform-state](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks#set-up-azure-storage-to-store-terraform-state)


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
- service/              -> An example microservice.
- web/                  -> Example microservice with a front-end.

## Starting the microservices application

### Using Vagrant for development

Docker/Docker-Compose is required to run this example microservices application, but if you don't want to install these directly on your host OS you can use a virtual machine (VM) under Vagrant and Virtual Box for development. Follow the steps in this section to boot the VM and then start the microservices application.

To proceed in this section you must have Vagrant and Virtual Box installed.

Boot the VM:

    vagrant up

Shell into the VM's OS:

    vagrant ssh

In the VM, run:

    cd /vagrant

    sudo docker-compose up

To build after you change code:

    sudo docker-compose up --build

A web page is now available on the host OS:

    http://127.0.0.1:7000/

An basic/example API is also available on the host OS:

    http://127.0.0.1:7100/api/data

The Mongodb database is available on the host OS:

    mongodb://127.0.0.1:7200

In the dev environment updates to the code on the host OS automatically flow through to the microservices in the Docker containers which are rebooted automatically using nodemon. This means you can edit code without having to restart Docker-Compose.

### Using Docker / Docker-Compose for development

If you have Docker/Docker-Compose installed directly on your host OS you don't need Vagrant or Virtual Box. Follow the steps in this section to book the microservices application for developent using Docker-Compose.

To proceed in this section you must have Docker/Docker-Compose installed.
Check ./scripts/provision-dev-vm.sh for example installation commands.

Change directory to the microservices application:

    cd nodejs-microservices-example

Run:

    docker-compose up

To build after you change code:

    docker-compose up --build

A web page is now available:

    http://127.0.0.1:80/

An basic/example API is also available:

    http://127.0.0.1:8080/api/data

The Mongodb database is available:

    mongodb://127.0.0.1:27017

In the dev environment updates to the code on the host OS automatically flow through to the microservices in the Docker containers which are rebooted automatically using nodemon. This means you can edit code without having to restart Docker-Compose.

## Starting the application in production

### Provision the cloud system using Terraform

Please have Terraform and Azure CLI installed.
Check provision-dev-vm.sh for example installation commands.

#### Environment variables for provisioning (Azure)

Environment variables must be set before running these scripts.

To push images to your private Docker register set these variables:
- DOCKER_REGISTRY -> The hostname for your Docker registry.
- DOCKER_UN -> Username for your Docker registry.
- DOCKER_PW -> Password for your Docker registry.
- VERSION -> The version of the software you are releasing, used to tag the Docker image..

To provision this application in the cloud you need to set the following environment variables to authenticate with Azure:

- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET 
- ARM_TENANT_ID

Another simpler way to authenticate is to use the following command (although this is manual and so won't work for continous delivery):

    az login

For more details on these environment variables please see [the Terraform docs for the Azure provider]  (https://www.terraform.io/docs/providers/azurerm/index.html#argument-reference).

For storing Terraform state in Azure storage set these environment variables:
- TF_BACKEND_RES_GROUP
- TF_BACKEND_STORAGE_ACC
- TF_BACKEND_CONTAINER

For storing and Terraform state and to select the Kubernetes cluster for deployment, set the following environment variable:
- ENVIRONMENT -> Set this to 'test' or 'production'.

#### Run scripts to build, provision and deploy

Have Vagrant and Virtual box installed.

Boot the VM:

    vagrant up

Shell into the VM:

    vagrant ssh

In the VM, run:

    cd /vagrant

Before running each script, please ensure it is flagged as executable, eg:

    chmod +x ./scripts/build-image.sh

The first time you do a build you need a Docker registry to push images to, run the follow script to provision your private Docker registry:

    ./scripts/provision-docker-registry.sh

Please take note of the username and password that are printed out after the Docker registry is created. You'll need to set these as environment variables as described in the previous section to be able to push your images to the registry.

Build the Docker image:

    sudo -E ./scripts/build-image.sh service
    sudo -E ./scripts/build-image.sh web

Push the Docker image to the Docker registry:

    sudo -E ./scripts/push-image.sh service
    sudo -E ./scripts/push-image.sh web

Now provision your Kubernetes cluster:

    sudo -E ./scripts/provision-kubernetes.sh

You can also run all the build scripts in go using:

    sudo -E ./scripts/build.sh

NOTE: 'sudo' is used when running the provisioning scripts under the Vagrant VM, but not when running under Bitbucket Pipelines.

### Integration with Bitbucket Pipelines

This repo integrates with Bitbucket Pipelines for continuous integration / delivery.

If you put this repo in Bitbucket it will run the script in the file bitbucket-pipelines.yml on each push to the repository. This builds the Docker containers, copies the images to your private Docker Registry, provisions the environment on Azure and deploys the code.

Please make sure you have created a private Docker registry already as mentioned in the previous section.

Please see the earlier section that lists [the environment variables you must set in Bitbucket](https://confluence.atlassian.com/bitbucket/variables-in-pipelines-794502608.html)

Although please don't set the VERSION environment variable for Bitbucket, that's already set to the build number from Bitbucket Pipelines.

## Testing

### Unit testing

Each service can be tested indepdently, but that's not included in this example.
You just need to install Jest (or other) then write some tests, then hook up the npm test script so you can run:

    npm test

### Integration testing

Integration testing can also be done using Jest.

### API / UI Testing

My preference at the moment is to use Cypress for both API and UI testing.

Please see this repo for an example: https://github.com/ashleydavis/cypress-example

## Resources

Setting up Terraform for Azure
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure

Creating a service principle:
https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html

https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html

Great video from Scott Hanselman
https://www.youtube.com/watch?v=iECZMWIQfgc

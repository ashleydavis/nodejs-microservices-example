# nodejs-microservices-example

Example of a monorepo with multiple Node.js microservices (using Docker, Docker-Compose and Kubernetes) that have separate CI/CD pipelines. 

This allows the convenience of a monorepo but with the flexibility of independent deployment schedules that makes microservices so good.

This code repo accompanies my blog post on [creating separate CI/CD pipelines in a monorepo](https://www.codecapers.com.au/separate-cd-pipelines-for-microservices-in-a-monorepo/).

Learn about building with microservices with my book [Bootstrapping Microservices](http://bit.ly/2o0aDsP).

[Support my work](https://www.codecapers.com.au/about#support-my-work)

# Project layout

```
nodejs-microservices-example
│   docker-compose.yml      -> Docker Compose file for development & testing.
│   package-lock.json
│   package.json
│   README.md
│
├───.github
│   └───workflows
│           db.yaml         -> Deploys the Database, this workflow is manually invoked from GitHub Actions.
│           gateway.yaml    -> CD pipeline for the gateway microservice.
│           worker.yaml     -> CD pipeline for an example worker microservice.
│
├───db-fixture              -> Loads database fixtures into the database.
│
├───gateway                 -> Code and Docker files for the gateway microservice.
│   │   Dockerfile-dev
│   │   Dockerfile-prod
│   │   nodemon.json
│   │   package-lock.json
│   │   package.json
│   │   README.MD
│   │
│   └───src
│           index.js
│
├───scripts                 -> Deployment helper scripts.
│   │   build-image.sh        -> Builds a Docker image.
│   │   push-image.sh         -> Publishes a Docker image.
│   │
│   └───kubernetes          -> Kubernetes configuration files.
│           db.yaml           -> Database configuration.
│           gateway.yaml      -> Gateway microservice configuration.
│           worker.yaml       -> Worker microservice configuration.
│
└───worker                  -> Code and Docker files for the worker microservice.
    │   .dockerignore
    │   Dockerfile-dev
    │   Dockerfile-prod
    │   nodemon.json
    │   package-lock.json
    │   package.json
    │   README.MD
    │
    └───src
            index.js
```

# Setup

- You should have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed.
- To deploy you'll need [to create a container registry and Kubernetes cluster](https://www.codecapers.com.au/kub-cluster-quick-2/).
  - I recomend using Digital Ocean or Azure, because they make Kubernetes easy or Digital Ocean because it makes Kubernetes cheap.
  
Clone the example repo:

```bash
git clone https://github.com/ashleydavis/nodejs-microservices-example.git
```

# Starting the application for development

Follow the steps in this section to start the microservices application for developent using Docker.

Change directory to the microservices application:

```bash
cd nodejs-microservices-example
```

Use Docker Compose to start the microservies application:

```bash
docker compose up --build
```

A web page is now available:

    http://127.0.0.1:4000

An example REST APIs are available:

    http://127.0.0.1:4000/api/data
    http://127.0.0.1:4001/api/data

The Mongodb database is available:

    mongodb://127.0.0.1:4002

This development environment is configured for [live reload](https://www.codecapers.com.au/live-reload-across-the-stack/) across microservices. Any changes you make to the code for the microservices in this code repository will cause those microservices to automatically reload themselves.

# Deploy the application to Kubernetes

At this point you need a Kubernetes cluster! For help creating one please see my book, [Bootstrapping Microservices](http://bit.ly/2o0aDsP).

## Set environment variables

These environment variables must be set before running these scripts:

- CONTAINER_REGISTRY -> The hostname for your container registry.
- REGISTRY_UN -> Username for your container registry.
- REGISTRY_PW -> Password for your container registry.
- VERSION -> The version of the software you are releasing, used to tag the Docker image.

## Build, publish and deploy

Before running each script, please ensure it is flagged as executable, eg:

```bash
chmod +x ./scripts/build-image.sh
```

Build Docker images:

```bash
./scripts/build-image.sh worker
./scripts/build-image.sh gateway
```

Publish Docker images to your container registry:

```bash
./scripts/push-image.sh worker
./scripts/push-image.sh gateway
```

To deploy to Kubernetes you need [Kubectl configured to connect to your cluster](https://www.codecapers.com.au/kub-cluster-quick-2/).

To deploy the MongoDB database:

```bash
kubectl apply -f ./scripts/kubernetes/db.yaml
```

For the next bit you need Node.js isntalled so that you can use [Figit](https://www.npmjs.com/package/figit) to expand the templated Kubenetes configuration files.

Install dependencies (thus installling Figit):

```bash
npm install
```

Then deploy the worker, using Figit to fill the blanks in the configuration file and piping the result to Kubectl:

```bash
npx figit ./scripts/kubernetes/worker.yaml --output yaml | kubectl apply -f -
```

Then deploy the gateway, again using Figit and Kubectl:

```bash
npx figit ./scripts/kubernetes/gateway.yaml --output yaml | kubectl apply -f -
```

## Check your deployment 

Check the status of pods and deployments:

```bash
kubectl get pods
kubectl get deployments
```

To find the IP address allocated to the web server, invoke:

```bash
kubectl get services
```

Pull out the EXTERNAL-IP address for the gateway service and put that into your web browser. You should see the hello world message in the browser.

To check console logging for the Node.js app:

```bash
kubectl logs <pod-name>
```

Be sure the actual name of the pod for `<pod-name>` that was in the output from `kubectl get pods`.

## Destroy the deployments

To destroy all the deployments when you are done:

```bash
kubectl delete -f ./scripts/kubernetes/db.yaml
```

```bash
npx figit ./scripts/kubernetes/worker.yaml --output yaml | kubectl delete -f -
```

```bash
npx figit ./scripts/kubernetes/gateway.yaml --output yaml | kubectl delete -f -
```

## Continuous delivery with GitHub Actions

This repo contains multiple GitHub Actions workflow configurations for automatic deployment to Kubernetes when the code for the each microservice changes (you can also manually invoke the workflows to trigger deployment even when the code hasn't changed).

Note that these CD pipelines are configured to be independent. When you push code changes for the gateway microservice, only that microservice will be built and deployed. Likewise, when you push code for the worker microservice, only that microservice will be deployed.

This allows us to have multiple microservices in a monorepo, but with the flexibility of separate deployment pipelines.

### Environment variables

To get the deployment pipelines working for your own code repository you will need to configure some environent variables as GitHub Secrets for your repository on GitHub.

Add the environment variables specified above: CONTAINER_REGISTRY, REGISTRY_UN nad REGISTRY_PW.

You will also need to add your Kubernetes configuration (encoded as base64) to a GitHub Secret called KUBE_CONFIG. 

You can encode your local configuration like this:

```bash
cat ~/.kube/config | base64
```

Cut and paste the result into the KUBE_CONFIG secret.

If you are working with Azure you can download and encode config using [the Azure CLI tool](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli):

```bash
az aks get-credentials --resource-group <resource-group> --name <cluster-name> -f - | base64
```

Cut and paste the result into the KUBE_CONFIG secret.

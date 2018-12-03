# nodejs-microservices-example

Example of dev and production Node.js microservices setup using Docker, Docker-Compose, Kubernetes and Terraform.

Based on some of my previous examples:
- https://github.com/ashleydavis/docker-compose-nodejs-example
- https://github.com/ashleydavis/docker-compose-nodejs-with-typescript-example

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

Web page now available:

    http://127.0.0.1:7000/

API available:

    http://127.0.0.1:7100/data

Database available:

    mongodb://127.0.0.1:7200

### Using Docker / Docker-Compose for development

Have docker / docker compose installed.
Check vagrant-provision-vm.sh for example installation commands.

Run:

    sudo docker-compose up

Web page now available:

    http://127.0.0.1:80/

API available:

    http://127.0.0.1:8080/data

Database available:

    mongodb://127.0.0.1:27017

### Provision the cloud system using Terraform

todo

## Testing

### Unit testing

Each service can be tested indepdently, but that's not included in this example.
You just need to install Jest (or other) then write some tests, then hook up the npm test script so you can run:

    npm test

### Integration testing

todo

### UI TEsting

todo

# Apache Hudi Demo Using AWS DMS CDC, EMR, and Glue Catalog

Demonstrate a simple Hudi data workflow in AWS using a mysql RDS as data source and S3 as storage for Hudi tables.
This project also showcase infrastructure as code patern by using Ansible to orchestrate the built and deployment of the components.

## Requirements

* AWS CLI
* Python 3.5+
* Ansible 2.9+
* [amazon.aws ansible](https://galaxy.ansible.com/amazon/aws) module collection:
    - `ansible-galaxy collection install amazon.aws`


## Architecture

![Architecture](./docs/architecture.png)


## Project Structure


## Deployment
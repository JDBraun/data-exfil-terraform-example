# Data Exfiltration Architecture - Workspace + Unity Catalog Deployment Example

There are no guarantees or warranties associated with this example.

# Getting Started

1. Clone this Repo 

2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)

3. Fill out `example.tfvars` and place in `aws` directory

5. CD into `aws`

5. Run `terraform init`

6. Run `terraform validate`

7. From `aws` directory, run `terraform plan -var-file ../example.tfvars`

8. Run `terraform apply -var-file ../example.tfvars`


# Network Diagram

![Architecture Diagram](https://github.com/JDBraun/data-exfil-terraform-example/blob/master/img/Network%20Topology.png)
# Introduction

This code shows how a downstream data product would need permissions to read from an upstream data product. 

## Setup

https://www.terraform.io/docs/providers/google/guides/getting_started.html

Setup infrastructure provisioning service account with name `data-mesh-base-infra-provision` and role `Project Owner`. 

Download the service account key and use it as the `account.json` to provision the infra

Create a <file name of your choice>.tfvars with your project name and project id

## Infra Provisioning

```
terraform init
terraform plan -var-file=<path of your tf vars>
terraform apply -var-file=<path of your tf vars>
```

If you are using the data-mesh-demo gcp project then the path is env/dev.tfvars

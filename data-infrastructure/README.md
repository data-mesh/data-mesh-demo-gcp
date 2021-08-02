# Introduction

This code shows how a downstream data product would need permissions to read from an upstream data product. 

## Setup

https://www.terraform.io/docs/providers/google/guides/getting_started.html

Setup infrastructure provisioning service account with name `data-mesh-base-infra-provision` and role `Project Owner`. 

Download the service account key and use it as the `account.json` to provision the infra

Create a <file name of your choice>.tfvars with your project name and project id in /base-infra/env

## Base Infra Provisioning

```
export WORKING_DIR=/base-infra
./init.sh
./plan.sh -var-file=<path of your tf vars>
./apply.sh -var-file=<path of your tf vars>
```

If you are using the data-mesh-demo gcp project then the path of your tf vars is env/dev.tfvars

## Data Product A Infra Provisioning

```
export WORKING_DIR=/data-products/data-product-a
./init.sh
./plan.sh -var-file=env/dev.tfvars
./apply.sh -var-file=env/dev.tfvars
```

If you are using the data-mesh-demo gcp project then the path of your tf vars is env/dev.tfvars

## Data Product B Infra Provisioning

```
export WORKING_DIR=/data-products/data-product-b
./init.sh
./plan.sh -var-file=env/dev.tfvars
./apply.sh -var-file=env/dev.tfvars
```

If you are using the data-mesh-demo gcp project then the path of your tf vars is env/dev.tfvars
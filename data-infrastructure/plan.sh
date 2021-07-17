docker run -i -t -v $PWD:$PWD -w $PWD \
hashicorp/terraform:0.13.7 \
plan -var-file=env/dev.tfvars

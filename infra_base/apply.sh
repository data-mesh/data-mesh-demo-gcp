docker run -i -t -v $PWD:$PWD -w $PWD \
hashicorp/terraform:0.13.7 \
apply -var-file=env/dev.tfvars
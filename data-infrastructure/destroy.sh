docker run -i -t -v $PWD:$PWD -w $PWD \
hashicorp/terraform:0.13.7 \
destroy -var-file=env/dev.tfvars

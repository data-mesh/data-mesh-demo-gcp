docker run -i -t -v $PWD:$PWD -w $PWD/$WORKING_DIR \
hashicorp/terraform:0.13.7 \
destroy $1

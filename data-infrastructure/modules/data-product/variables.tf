variable "data_product_name" {
    type = string
}

variable "location" {
    type = string
    default = "US"
}

# inputs are for data products that might need to ingest external sources of data into their system or for error datasets
# It could be fetching daily snapshots from some ftp server 
# It could be fetching daily snapshots from some api 
# In some enterprises it could be that you need to give an external data producer a data storage account, 
  # you can simply do that by provisioning an external data product with a storage bucket and an identity for it
  # and manage access to it via the consumer group on the storage account where you can grant your system read permissions. 
variable "inputs" {
  type = list(object({
    name = string
    input_type = string
  }))

  //https://discuss.hashicorp.com/t/validate-list-object-variables/18291/2
  validation {
  condition = length([
      for input in var.inputs : true
      if contains(["Storage", "SQL"], input.input_type)
    ]) == length(var.inputs)
    error_message = "All inputs must have input type of either Storage or SQL."
  }
  default=[]
}

variable "outputs" {
  type = list(object({
    name = string
    output_type = string
    consumer_email = string
  }))
  default = []
  validation {
    condition = length([
        for output in var.outputs : true
        if contains(["Storage", "SQL"], output.output_type)
      ]) == length(var.outputs)
      error_message = "All outputs must have output type of either Storage or SQL."
  }
}

variable "compute" {
    type = bool
    default = false
}

variable "project_name" {
  type= string
}

variable "project_id" {
  type= string
}
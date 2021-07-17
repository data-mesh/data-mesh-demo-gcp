variable project_name {
  type = string
  default = ""
  description = "Project name where resources will be provisioned."
}

variable project_id {
  type = string
  default = ""
  description = "Project id where resources will be provisioned."
}

variable consumer_email {
  type = string
  description = "Email of google service account that is a consumer of the upstream data"
}

variable data_product_account_name {
  type = string
  description = "data product service account name"
}

variable output_port_data_set_name {
  type = list(string)
}

variable data_product_name {
  type = string
}

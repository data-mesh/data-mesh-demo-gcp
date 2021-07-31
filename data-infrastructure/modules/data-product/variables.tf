variable "data_product_name" {
    type = string
}

variable "location" {
    type = string
    default = "US"
}

variable "inputs" {
  type = list(object({
    name = string
    input_type = string
  }))

  validation {
    condition = alltrue([
      for input in var.inputs : contains(["Storage", "SQL", "DataProductOutput"], input.input_type)
    ])
    error_message = "All inputs must have input type of either Storage, SQL or DataProductOutput."
  }
  
}


variable "outputs" {
  type = list(object({
    name = string
    type = string
    owner_email = string
    consumer_email = string
    location = string
  }))
  default = []
}

variable "compute" {
    type = boolean
    default = false
}
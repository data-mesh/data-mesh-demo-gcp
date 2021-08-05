variable dataset_name{
    type = string
}

variable data_product_name{
    type=string
}

variable location{
    type=string
    default= "US"
}

variable owner_email{
    type = string
}

variable consumers{
    type = list(object({
        email = string
    }))
    default = []
}
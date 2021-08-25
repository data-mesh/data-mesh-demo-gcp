module "data_product" {
  source   = "../../modules/data-product"
  data_product_name ="dataproducte"
  inputs=[
    {
      "name"="storage-e-1"
      "input_type"="Storage"
    }
  
  ]
  outputs=[
    {
      "name"="dataset1"
      "output_type"="SQL"
      consumer_email="data-product-e-consumers@thoughtworks.com"
    },
    {
      "name"="storage-e-1"
      "output_type"="Storage"
      consumer_email="data-product-e-consumers@thoughtworks.com"
    },
    ]
  compute=true
  project_name= var.project_name
  project_id = var.project_id
}

output "data_flow_bucket" {
  value=module.data_product.data_flow_bucket
}

output "outputs" {
  value = module.data_product.outputs_addresses
}

output "inputs" {
  value = module.data_product.inputs_addresses
}
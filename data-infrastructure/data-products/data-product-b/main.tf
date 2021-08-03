module "data_product" {
  source   = "../../modules/data-product"
  data_product_name ="dataproductb"
  inputs=[
  ]
  outputs=[
    {
      "name"="dataset1"
      "output_type"="SQL"
      consumer_email="data-product-b-consumers@thoughtworks.com"
    },
    {
      "name"="storage_b_1"
      "output_type"="Storage"
      consumer_email="data-product-b-consumers@thoughtworks.com"
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
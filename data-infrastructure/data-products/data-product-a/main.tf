module "data_product" {
  source   = "../../modules/data-product"
  data_product_name ="dataproducta"
  inputs=[
    {
      "name"="storage_a_input_1"
      "input_type"="Storage"
    }
  
  ]
  outputs=[
    {
      "name"="dataset1output"
      "output_type"="SQL"
      consumer_email="data-product-a-consumers@thoughtworks.com"
    },
    {
      "name"="storage_a_output_1"
      "output_type"="Storage"
      consumer_email="data-product-a-consumers@thoughtworks.com"
    },
    ]
  compute=true
  project_name= var.project_name
  project_id = var.project_id
}
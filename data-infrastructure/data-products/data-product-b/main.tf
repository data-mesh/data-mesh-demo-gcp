module "data_product" {
  source   = "../../modules/data-product"
  data_product_name ="dataproductb"
  inputs=[
  ]
  outputs=[
    {
      "name"="dataset1output"
      "output_type"="SQL"
      consumer_email="data-product-b-consumers@thoughtworks.com"
    },
    {
      "name"="storage_b_output_1"
      "output_type"="Storage"
      consumer_email="data-product-b-consumers@thoughtworks.com"
    },
    ]
  compute=true
  project_name= var.project_name
  project_id = var.project_id
}
from jinja2 import Template

import subprocess

# Get the file changes in data-infrastructure/data-products

# head = subprocess.run(
#                           ['git', 'rev-parse', 'HEAD'],
#                           check=True,
#                           capture_output=True
#                         ).stdout.decode('utf-8').strip()

# base = subprocess.run(
#                           ['git', 'rev-parse', 'HEAD~1'], 
#                           check=True,
#                           capture_output=True
#                         ).stdout.decode('utf-8').strip()

# print('Comparing {}...{}'.format(base, head))


changes = subprocess.run(
    ['git', 'diff-tree', '-r', '--no-commit-id', '--name-status', 'HEAD', '../data-infrastructure/data-products'],
    check=True,
    capture_output=True
).stdout.decode('utf-8').splitlines()

changes=['M\t.data-infrastructure/data-products/data-product-a/main.tf', 'M\t.data-infrastructure/data-products/data-product-b/main.tf']

print('Printing changes {}'.format(changes))

# Get data products to provision
def get_data_products_folders(diffs):
    for diff in diffs: 
        print('Print diff split'.format(diff.split("\t")))
        return [] 

data_products_folders = get_data_products_folders(changes)

print('Printing data products folders {}'.format(data_products_folders))

# Create the data for rendering the template
## TODO
data = {
    "data_products": [
        {
            "name": "data-product-a",
            "dir": "data-infrastructure/data-products/data-product-a"
        }, 
        {   
            "name": "data-product-b", 
            "dir": "data-infrastructure/data-products/data-product-b"
        }],
}

print(data)

# Read the template file 
# Open a file: file
file = open('./templates/provision-data-product.yml',mode='r')
# read all lines at once
template = file.read()
# close the file
file.close()

# Generate the pipeline config
j2_template = Template(template)
output=j2_template.render(data)

with open('../configs/generated_config.yml', 'w') as f:
    f.write(output)
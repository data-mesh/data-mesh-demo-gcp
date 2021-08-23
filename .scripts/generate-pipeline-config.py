from jinja2 import Template
import subprocess

# Get the file changes in data-infrastructure/data-products
changes = subprocess.run(
    ['git', 'diff-tree', '-r', '--no-commit-id', '--name-status', 'HEAD', '../data-infrastructure/data-products'],
    check=True,
    capture_output=True
).stdout.decode('utf-8').splitlines()

print('Printing changes {}'.format(changes))

# Get data products to provision
def get_data_products_configs(gitChanges):
    configs = dict()
    for gitChange in gitChanges: 
        gitChangeArray = gitChange.split('\t')
        print('Print diff split {}'.format(gitChangeArray))

        if gitChangeArray[0].startswith('M') | gitChangeArray[0].startswith('A'):
                print('file path that changed or added {}'.format(gitChangeArray[1]))
                data_product_dir=gitChangeArray[1].split('/')[2]
                configValue = {
                        "name": data_product_dir,
                        "dir": 'data-infrastructure/data-products/{}'.format(data_product_dir)
                    }
                configKey = gitChangeArray[1].split('/')[2]
                configs[configKey] = configValue
    return configs

data_product_configs = get_data_products_configs(changes)
print('Printing data products configs {}'.format(data_product_configs))

if len(data_product_configs) > 0:
    # Create the data for rendering the template
    template_data = {
        "data_products": list(data_product_configs.values())
    }
    print("Printing the template data {}".format(template_data))

    # Read the template file 
    # Open a file: file
    file = open('./templates/provision-data-product.yml',mode='r')
    # read all lines at once
    template = file.read()
    # close the file
    file.close()

    # Generate the pipeline config
    j2_template = Template(template)
    output=j2_template.render(template_data)

    with open('../configs/generated_config.yml', 'w') as f:
        f.write(output)

else:
    default_pipeline = ""
    with open('./templates/default-do-nothing.yml',mode='r') as f:
        default_pipeline = f.read()
    with open('../configs/generated_config.yml', 'w') as f:
        f.write(default_pipeline)
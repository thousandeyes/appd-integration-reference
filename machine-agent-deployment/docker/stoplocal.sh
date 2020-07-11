#!/bin/bash

terraform init terraform/local > /dev/null
terraform destroy -auto-approve terraform/local > /dev/null
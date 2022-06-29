#!/bin/bash
if [ ! -e $1 ] ; then
  echo "Missing env directory: "$1
  exit 1
fi

echo "Starting terraform at: "$1
cd $1
ln ../stack/main.tf main.tf
ln ../stack/variables.tf variables.tf

pwd
ls
ln -l

terraform init
terraform plan -var-file="terraform.tfvars" --out=plan.tfplan


unlink main.tf
unlink variables.tf
# Lakitu Packer Script

## Getting started

Copy the `application.properties.example` to `application.properties` and create Lakitu API keys that you want.
Copy the `terraform.tfvars.example` to `terraform.tfvars` and put your AWS API keys in there

## Building an AMI

This builds an AMI using packer an ansible

    packer build lakitu.json

To build a specific version

    packer build -var 'version=0.8.2' lakitu.json

To build a specific version with machine readable output written to a file

    packer -machine-readable build -var 'version=0.8.2' lakitu.json |tee build-0.8.2.packer

## Launching to AWS

    terraform plan
    terraform apply

to deploy a specific AMI

    terraform plan -var "lakitu_ami=ami-b71690dc"
    terraform apply -var "lakitu_ami=ami-b71690dc"

to get the AMI out of the machine readable output

    export AMI_INFO=`grep amazon-ebs,artifact,0,id, build-0.8.2.packer |cut -d , -f 6`
    export AWS_REGION=`echo "${AMI_INFO}" |cut -d : -f 1`
    export AWS_IMAGE_ID=`echo "${AMI_INFO}" |cut -d : -f 2`
    terraform apply -var "aws_region=${AWS_REGION}" -var "lakitu_ami=${AWS_IMAGE_ID}"


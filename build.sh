#!/bin/bash -e

URL=https://bintray.com/mnclimbingcoop/maven/lakitu/_latestVersion
LATEST_VERSION=`curl -is $URL |grep Location: |sed -e 's#.*https://bintray.com/##' |cut -d \/ -f 4`

echo "Building AMI for Lakitu version '${LATEST_VERSION}'"

if [ "$LATEST_VERSION" != "" ]; then
    packer -machine-readable build -var "version=${LATEST_VERSION}" lakitu.json |tee build-${LATEST_VERSION}.packer

    AMI_INFO=`grep amazon-ebs,artifact,0,id, build-${LATEST_VERSION}.packer |cut -d , -f 6`
    if [ "${AMI_INFO}" != "" ]; then
        AWS_REGION=`echo "${AMI_INFO}" |cut -d : -f 1`
        AWS_IMAGE_ID=`echo "${AMI_INFO}" |cut -d : -f 2`

        echo "Deploying AMI: '${AWS_IMAGE_ID}'"

        if [ "${AWS_REGION}" != "" ] && [ "${AWS_IMAGE_ID}" != "" ]; then
            terraform apply -var "aws_region=${AWS_REGION}" -var "lakitu_ami=${AWS_IMAGE_ID}"
        fi
    fi
fi

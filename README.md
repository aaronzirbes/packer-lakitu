# Lakitu Packer Script

## Getting started

Copy the `application.properties.sample` to `application.properties` and create API keys that you want.

## Building

This builds an AMI using packer an ansible

    packer build -var "version=0.8.0" lakitu.json


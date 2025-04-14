#!/bin/bash

mkdir -p .github/workflows
cat << EOF > .github/workflows/dynamic-deploy.yml
name: Dynamic Deploy Terraform Resources
EOF
echo "File created successfully"
cat .github/workflows/dynamic-deploy.yml
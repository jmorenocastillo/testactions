#!/bin/bash
# Descubrir recursos
          RESOURCES=$(find . -maxdepth 1 -type d -not -path '.' -not -path './.*' -exec basename {} \;)
          echo "Resources found: $RESOURCES"
          
          # Verificar que RESOURCES no esté vacío
          if [ -z "$RESOURCES" ]; then
            echo "Error: No resources found"
            exit 1
          fi

          # Crear el YAML dinámico línea por línea
          mkdir -p .github/workflows
          echo "name: Dynamic Deploy Terraform Resources" > .github/workflows/dynamic-deploy.yml
          echo "" >> .github/workflows/dynamic-deploy.yml
          echo "on:" >> .github/workflows/dynamic-deploy.yml
          echo "  workflow_call:" >> .github/workflows/dynamic-deploy.yml
          echo "" >> .github/workflows/dynamic-deploy.yml
          echo "env:" >> .github/workflows/dynamic-deploy.yml
          echo "  AZURE_STORAGE_ACCOUNT: \${{ secrets.AZURE_STORAGE_ACCOUNT }}" >> .github/workflows/dynamic-deploy.yml
          echo "  AZURE_STORAGE_KEY: \${{ secrets.AZURE_STORAGE_KEY }}" >> .github/workflows/dynamic-deploy.yml
          echo "  CONTAINER_NAME: tfstate" >> .github/workflows/dynamic-deploy.yml
          echo "  ENVIRONMENTS: dev pre pro" >> .github/workflows/dynamic-deploy.yml
          echo "" >> .github/workflows/dynamic-deploy.yml
          echo "jobs:" >> .github/workflows/dynamic-deploy.yml

          # Añadir un job por cada recurso
          for RESOURCE in $RESOURCES; do
            echo "Generating job for $RESOURCE"
            cat << EOF >> .github/workflows/dynamic-deploy.yml
            $RESOURCE:
              runs-on: ubuntu-latest
              steps:
                - name: Checkout repository
                  uses: actions/checkout@v4

                - name: Setup Terraform
                  uses: hashicorp/setup-terraform@v3
                  with:
                    terraform_version: 1.5.0

                - name: Deploy Terraform for $RESOURCE
                  env:
                    ARM_CLIENT_ID: \${{ secrets.ARM_CLIENT_ID }}
                    ARM_CLIENT_SECRET: \${{ secrets.ARM_CLIENT_SECRET }}
                    ARM_SUBSCRIPTION_ID: \${{ secrets.ARM_SUBSCRIPTION_ID }}
                    ARM_TENANT_ID: \${{ secrets.ARM_TENANT_ID }}
                  run: |
                    for ENV in \$ENVIRONMENTS; do
                      echo "Deploying $RESOURCE in \$ENV..."
                      cd "$RESOURCE"/"\$ENV"
                      terraform init -backend-config="storage_account_name=\$AZURE_STORAGE_ACCOUNT" \
                                     -backend-config="container_name=\$CONTAINER_NAME" \
                                     -backend-config="access_key=\$AZURE_STORAGE_KEY" \
                                     -backend-config="key=$RESOURCE-\$ENV.tfstate"
                      terraform apply -auto-approve
                      cd ../..
                    done
EOF
          done
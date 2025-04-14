#!/bin/bash
          if [ -f .github/workflows/dynamic-deploy.yml ]; then
            rm .github/workflows/dynamic-deploy.yml
            echo "dynamic-deploy.yml deleted"
          else
            echo "dynamic-deploy.yml does not exist, nothing to delete"
          fi
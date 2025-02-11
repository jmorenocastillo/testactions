name: Run Pro Script

on: [push]

jobs:
    run-pro-script:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout repository
            uses: actions/checkout@v2

        - name: Run pro.sh script
            run: bash /C:/actiosn/testactions/pro/pro.sh
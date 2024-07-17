## Overview

This README provides instructions on how to set up and run the performance test script. The script performs specific tasks that are dependent on environment variables. Please follow the steps below to ensure the script runs correctly.

###################################
## create-hosted-clusters.sh
###################################

## Environment Variables

Before running the script, you need to export the required environment variables. 

### Setting Environment Variables

```sh
export AWS_SECRET_ACCESS_KEY=value
export AWS_ACCESS_KEY_ID=value
export OCM_TOKEN=value
export ES_SERVER="https://xx"
export ES_INDEX=value
```

Alternatively, you can create a file named `create-hosted-clusters.env` in the same directory 
```sh
# .env file
export AWS_SECRET_ACCESS_KEY=value
export AWS_ACCESS_KEY_ID=value
export OCM_TOKEN=value
export ES_SERVER="https://xx"
export ES_INDEX=value
```

Then, run the following command:

```sh
source create-hosted-clusters.env
```

## Running the Script
To run the script, use the following command:

```sh
./create-hosted-clusters.sh
```

## Troubleshooting

If you encounter any issues while running the script, check the following:

- Ensure all required environment variables are set correctly.
- Verify the script has the necessary execute permissions.
- Check the script for any syntax errors or missing dependencies.


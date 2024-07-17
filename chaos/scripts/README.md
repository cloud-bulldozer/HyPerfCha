## Overview

This README provides instructions on how to set up and run the chaos test scripts.

###################################
## container-interrupt.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./container-interrupt.sh
```

###################################
## cpu-hog.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./cpu-hog.sh
```

###################################
## io-hog.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./io-hog.sh
```

###################################
## memory-hog.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./memory-hog.sh
```

###################################
## master-node-disruption.sh
###################################
## Environment Variables
Before running the script, you need to export the required environment variables. 

### Setting Environment Variables

```sh
export AWS_SECRET_ACCESS_KEY=value
export AWS_ACCESS_KEY_ID=value
```

## Running the Script
To run the script, use the following command:

```sh
./master-node-disruption.sh
```

###################################
## etcd-pod-disruption.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./etcd-pod-disruption.sh
```

###################################
## random-pod-disruption.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./random-pod-disruption.sh
```

###################################
## service-disruption.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./service-disruption.sh
```

###################################
## time-skew.sh
###################################
## Running the Script
To run the script, use the following command:

```sh
./time-skew.sh
```

###################################
## zone-outages.sh
###################################
### Setting Environment Variables

```sh
export VPC_ID=vpc-xxxxxxxxxxxxxxxxxx
export SUBNET_ID=[subnet-xxxxxxxxxxxxxxxxx]
export AWS_SECRET_ACCESS_KEY=value
export AWS_ACCESS_KEY_ID=value
```

## Running the Script
To run the script, use the following command:

```sh
./zone-outages.sh
```

## Troubleshooting

If you encounter any issues while running the script, check the following:

- Ensure all required environment variables are set correctly.
- Verify the script has the necessary execute permissions.
- Check the script for any syntax errors or missing dependencies.


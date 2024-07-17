#!/bin/bash
echo "This is a shell script to run Master node outage to understand availability, recovery and performance impact
"
echo "The current directory is, $PWD"

export ACTION="node_stop_start_scenario"
export LABEL_SELECTOR="node-role.kubernetes.io/worker"
export NODE_NAME="ip-10-0-0-52.ec2.internal"
export INSTANCE_COUNT=1
export RUNS=1
export TIMEOUT=180
export AWS_DEFAULT_REGION="us-east-1"
export ENABLE_ALERTS=true
export CONTAINER_NAME=master-node-disruption
export CHECK_CRITICAL_ALERTS=true


# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_mas
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_mas
podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_mas:/root/.kube/config:Z -v /tmp/alerts_mas:/root/kraken/config/alerts:Z -d quay.io/redhat-chaos/krkn-hub:node-scenarios

# Wait for container to exit
while [ "$(podman inspect --format '{{.State.Status}}' $CONTAINER_NAME )" == "running" ]; do
    sleep 1
done

EXIT_CODE=$(podman inspect $CONTAINER_NAME --format "{{.State.ExitCode}}")

#check if exit code is 0 and print message accordingly
if [[ $EXIT_CODE -eq 0 ]]; then
  echo $CONTAINER_NAME recovered
else
  echo $CONTAINER_NAME did not recovered
fi

rm /tmp/kubeconfig_mas
rm /tmp/alerts_mas
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


#!/bin/bash
echo "This is a shell script to run Master node outage to understand availability, recovery and performance impact
"
echo "The current directory is, $PWD"

export CLOUD_TYPE=aws
export DURATION=600
export AWS_DEFAULT_REGION="us-east-1"
export ENABLE_ALERTS=true
export CONTAINER_NAME=zone-outages

# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_zon
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_zon

podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_zon:/home/krkn/.kube/config:Z -v /tmp/alerts_zon:/root/kraken/config/alerts:Z -d quay.io/krkn-chaos/krkn-hub:zone-outages

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

rm /tmp/kubeconfig_zon
rm /tmp/alerts_zon
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


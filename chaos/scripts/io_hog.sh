
#!/bin/bash
echo "This is a shell script to run IO Hog to understand availability, recovery and performance impact
"
echo "The current directory is, $PWD"

export TOTAL_CHAOS_DURATION=360
export CONTAINER_NAME=io-hog
export MEMORY_CONSUMPTION_PERCENTAGE=90
export NODE_SELECTORS="node-role.kubernetes.io/worker="
export NUMBER_OF_WORKERS=10


# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_io
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_io
podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_io:/home/krkn/.kube/config:Z -v /tmp/alerts_io:/home/kraken/config/alerts:Z -d quay.io/krkn-chaos/krkn-hub:node-io-hog

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

rm /tmp/kubeconfig_io
rm /tmp/alerts_io
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME



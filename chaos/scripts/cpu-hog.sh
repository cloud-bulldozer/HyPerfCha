#!/bin/bash
echo "CPU hog scenario to simulate rogue process consuming huge amount of CPU leading to other pods starving and performance degradation"
echo "The current directory is, $PWD"


export CONTAINER_NAME=cpu-hog
export TOTAL_CHAOS_DURATION=360
export NODE_CPU_PERCENTAGE=90
export NODE_SELECTORS="node-role.kubernetes.io/worker="

# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_cpu
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_cpu

#podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_cpu:/root/.kube/config:Z -d quay.io/redhat-chaos/krkn-hub:node-cpu-hog
podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_cpu:/home/krkn/.kube/config:Z -d quay.io/krkn-chaos/krkn-hub:node-cpu-hog

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

rm /tmp/kubeconfig_cpu
rm /tmp/alerts_cpu
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME



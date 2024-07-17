#!/bin/bash
set -x
echo "This is a shell script to check etcd HA availability when disrupted at the container level"
echo "The current directory is, $PWD"

#Export the following environment variables
export NAMESPACE=openshift-etcd
export LABEL_SELECTOR="k8s-app=etcd"
export DISRUPTION_COUNT=1
export ACTION="1"
export RETRY_WAIT=60
export ENABLE_ALERTS=true
export CONTAINER_NAME=etcd-container-disruption
export CHECK_CRITICAL_ALERTS=false
export PATH=$PATH:/usr/local/bin

# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_con
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_con
podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_con:/home/krkn/.kube/config:Z -v /tmp/alerts_con:/home/kraken/config/alerts:Z -d quay.io/krkn-chaos/krkn-hub:container-scenarios

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

rm /tmp/kubeconfig_con
rm /tmp/alerts_con

# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


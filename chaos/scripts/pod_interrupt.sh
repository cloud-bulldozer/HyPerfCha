#!/bin/bash
echo "This is a shell script to check etcd HA availability when disrupted at the pod level"
echo "The current directory is, $PWD"

export NAMESPACE=openshift-etcd
export POD_LABEL="app=etcd"
export DISRUPTION_COUNT=1
export EXPECTED_POD_COUNT=3
export KILL_TIMEOUT=180
export WAIT_TIMEOUT=90
export ENABLE_ALERTS=true
export CONTAINER_NAME=etcd-pod-disruption
export CHECK_CRITICAL_ALERTS=false

# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_pod
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_pod
podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_pod:/home/krkn/.kube/config:Z  -v /tmp/alerts_pod:/home/kraken/config/alerts:Z -d quay.io/krkn-chaos/krkn-hub:pod-scenarios
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
rm /tmp/kubeconfig_pod
rm /tmp/alerts_pod

# get logs
podman logs $CONTAINER_NAME



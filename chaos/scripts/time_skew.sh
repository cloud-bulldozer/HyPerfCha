#!/bin/bash
echo "This is a shell script to time skew to understand availability, recovery and performance impact
"
echo "The current directory is, $PWD"

export CONTAINER_NAME=time-skew
export OBJECT_TYPE=pod
export LABEL_SELECTOR="k8s-app=etcd"
export ACTION=skew_date
export OBJECT_NAME=[]
export CONTAINER_NAME=time-scenarios
export NAMESPACE=""


# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_time
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_time

podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_time:/home/krkn/.kube/config:Z -d quay.io/krkn-chaos/krkn-hub:time-scenarios

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

rm /tmp/kubeconfig_time
rm /tmp/alerts_time
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


#!/bin/bash
echo "This is a shell script to  Disrupt control plane services including  Etcd, Api Server,  monitoring components including prometheus, ingress/router etc.  i.e take down the entire stack in the namespace to see how fast it recovers in addition to understanding the impact.
"
echo "The current directory is, $PWD"

export CONTAINER_NAME=service-disruption
export NAMESPACE=openshift-etcd
export SLEEP=15
export RUNS=1
export NODE_SELECTORS=”node-role.kubernetes.io/worker=”


# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

cp /root/kubeconfig /tmp/kubeconfig_ser
cp /opt/sti_ext/test_driver/harness/alerts/chaos/alerts /tmp/alerts_ser


podman run --name $CONTAINER_NAME --net=host --env-host=true -v /tmp/kubeconfig_ser:/home/krkn/.kube/config:Z  -d quay.io/krkn-chaos/krkn-hub:service-disruption-scenarios

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

rm /tmp/kubeconfig_ser
rm /tmp/alerts_ser
# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


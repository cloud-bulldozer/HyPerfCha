export CLUSTER_PREFIX=chaosper
export NUM_OF_CLUSTERS=1
export CLUSTER_PER_VPC=4
export AWS_REGION=us-east-1
export WORKER_SIZES=3,9,12
export LOG_FILE_PATH=/tmp/1hc.log
export BATCH_SIZE=1
export BATCH_INTERVAL=60
export HC_LOAD_DURATION=8h
export EXTRA_OPTION="--version 4.15.8"
export WORKER_TIMEOUT=60
export CLEANUP_INTERVAL=60
export CONTAINER_NAME=chaos-hcp-burner

# Check if container named "min" exists
if podman container exists $CONTAINER_NAME; then
    # If it exists, stop and remove the container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    echo "Container $CONTAINER_NAME has been deleted"
else
    echo "Container $CONTAINER_NAME does not exist"
fi

podman run \
        --env ES_SERVER=${ES_SERVER} \
        --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}  \
        --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}  \
        --env AWS_REGION=${AWS_REGION}  \
        --name $CONTAINER_NAME \
        --net=host \
        --env-host=true \
        -i -d quay.io/mukrishn/hcp-burner:firsttag \
        python3 hcp-burner.py --install-clusters --cluster-name-seed ${CLUSTER_PREFIX}  --platform rosa --subplatform hypershift --cluster-count ${NUM_OF_CLUSTERS} --batch-size ${BATCH_SIZE} --delay-between-batch ${BATCH_INTERVAL} --workers ${WORKER_SIZES} --wait-for-workers --workers-wait-time ${WORKER_TIMEOUT} --create-vpcs --clusters-per-vpc ${CLUSTER_PER_VPC} --service-cluster hs-sc-s5upt5l60 --aws-region ${AWS_REGION} --ocm-url https://api.stage.openshift.com --ocm-token ${OCM_TOKEN} --wildcard-options "${EXTRA_OPTION}" --es-url ${ES_SERVER} --es-index hypershift-wrapper-timers --es-insecure --log-level debug --log-file ${LOG_FILE_PATH} --enable-workload --workload-duration ${HC_LOAD_DURATION} --workload-jobs 9 --cleanup-clusters --delete-vpcs --workload-executor /usr/local/bin/kube-burner

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

# Search for string in logs and print matching lines
podman logs $CONTAINER_NAME


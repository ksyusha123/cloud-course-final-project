#!/bin/bash

echo "`(cat versions.json) | jq '.version = .version + 1'`"  > versions.json;
version=$(jq -r '.version' versions.json);
echo "new version: $version";
docker build -t ${FEEDBACK_API_REPOSITORY_NAME}:0.0.$version . ;
docker push ${FEEDBACK_API_REPOSITORY_NAME}:0.0.$version;
yc sls container revisions deploy \
	--folder-id ${FOLDER_ID} \
	--container-id ${FEEDBACK_API_CONTAINER_ID} \
	--memory 512M \
	--cores 1 \
	--execution-timeout 5s \
	--concurrency 4 \
	--environment AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID},AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY},DOCUMENT_API_ENDPOINT=${DOCUMENT_API_ENDPOINT},VERSION=$version \
	--service-account-id ${FEEDBACK_PROJECT_SA_ID} \
	--image "${FEEDBACK_API_REPOSITORY_NAME}:0.0.$version";

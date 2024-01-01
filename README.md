# Instruction  
1. Fill your yandex-cloud information
`yc config profile get <profile-name>`
Copy token, cloud-id and folder-id to `provider.tf`. 
`export FOLDER_ID=<folder-id>`

1. Initialize terraform
```
cd deploy
terraform init
```

1. Create database
```
terraform apply -target=yandex_ydb_database_serverless.feedback_db
export DOCUMENT_API_ENDPOINT=<feedback_db_document_api_endpoint>
```

1. Create service account and AWS key
```
terraform apply -target=yandex_iam_service_account.feedback_project_sa
export FEEDBACK_PROJECT_SA_ID=<feedback_project_sa_id>

terraform apply -target=yandex_iam_service_account_static_access_key.feedback_project_sa_static_key
export AWS_ACCESS_KEY_ID=<access_key>

terraform output -raw private_key
export AWS_SECRET_ACCESS_KEY=< private_key>
```

1. Add the roles for your service account
```
yc resource-manager folder add-access-binding ${FOLDER_ID} --role ydb.admin --subject serviceAccount:${FEEDBACK_PROJECT_SA_ID}
yc resource-manager folder add-access-binding ${FOLDER_ID} --role container-registry.images.puller --subject serviceAccount:${FEEDBACK_PROJECT_SA_ID}
yc resource-manager folder add-access-binding ${FOLDER_ID} --role serverless.containers.invoker --subject serviceAccount:${FEEDBACK_PROJECT_SA_ID}
yc resource-manager folder add-access-binding ${FOLDER_ID} --role serverless.functions.invoker --subject serviceAccount:${FEEDBACK_PROJECT_SA_ID}
yc resource-manager folder add-access-binding ${FOLDER_ID} --role storage.editor --subject serviceAccount:${FEEDBACK_PROJECT_SA_ID}
```

1. Configure aws-cli and create tables
```
aws dynamodb create-table \
    --table-name feedback \
    --attribute-definitions \
      AttributeName=id,AttributeType=S \
      AttributeName=username,AttributeType=S \
      AttributeName=text,AttributeType=S \
      AttributeName=datetime,AttributeType=S \
    --key-schema \
      AttributeName=id,KeyType=HASH \
    --endpoint ${DOCUMENT_API_ENDPOINT}

aws dynamodb create-table \
    --table-name replica \
    --attribute-definitions \
      AttributeName=key,AttributeType=N \
      AttributeName=value,AttributeType=N \
    --key-schema \
      AttributeName=key,KeyType=HASH \
    --endpoint ${DOCUMENT_API_ENDPOINT}
```

1. Create container-registry

```
terraform apply -target=yandex_container_registry.default
terraform apply -target=yandex_container_repository.feedback_api_repository

export FEEDBACK_API_REPOSITORY_NAME=<feedback_api_repository_name>
```

1. Create docker image of the app

```
yc container registry configure-docker
cd ../api
docker build -t ${FEEDBACK_API_REPOSITORY_NAME}:0.0.1 .
docker push ${FEEDBACK_API_REPOSITORY_NAME}:0.0.1
```

1. Create the app container and its revision

```
yc sls container create --name feedback-api-container --folder-id ${FOLDER_ID}
export FEEDBACK_API_CONTAINER_ID=<feedback-api-container-id>
```

```
yc sls container revisions deploy \
	--folder-id ${FOLDER_ID} \
	--container-id ${FEEDBACK_API_CONTAINER_ID} \
	--memory 512M \
	--cores 1 \
	--execution-timeout 5s \
	--concurrency 4 \
    --environment ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID},SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY},DOCUMENT_API_ENDPOINT=${DOCUMENT_API_ENDPOINT},VERSION=1 \
	--service-account-id ${FEEDBACK_PROJECT_SA_ID} \
	--image ${FEEDBACK_API_REPOSITORY_NAME}:0.0.1
```
1. Add service_account_id to all config files in openapi/ and container_id to openapi/api.yaml. 
To get service account id one can use `yc iam service-account list`

1. Create backend API-gateway
```
cd ../deploy
terraform apply -target=yandex_api_gateway.feedback_api_gateway
export FEEDBACK_API_GATEWAY_DOMAIN=<feedback_api_gateway_domain>
```


1. Create a bucket for web and load files
```
terraform apply -target=yandex_storage_bucket.feedback_website_bucket
export FEEDBACK_WEBSITE_BUCKET=<feedback_website_bucket>
```

```
cd ../web
aws --endpoint-url=https://storage.yandexcloud.net s3 cp --recursive !(update.sh) s3://${FEEDBACK_WEBSITE_BUCKET}
```

Paste feedback_website_bucket to openapi/website.yaml

1. Create website API-gateway
```
cd ../deploy
terraform apply -target=yandex_api_gateway.feedback_website_gateway
```

Scripts for updating are located in api/ and web/ folders.


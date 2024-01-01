locals {
  database_name = "feedback-project"
}

resource "yandex_ydb_database_serverless" "feedback_db" {
  name      = local.database_name
  folder_id = local.folder_id
  serverless_database {
    storage_size_limit = 1
  }
}

output "feedback_db_document_api_endpoint" {
  value = yandex_ydb_database_serverless.feedback_db.document_api_endpoint
}

output "feedback_db_path" {
  value = yandex_ydb_database_serverless.feedback_db.database_path
}
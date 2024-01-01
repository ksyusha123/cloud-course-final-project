locals {
  service_account_name_prefix = "feedback-project"
}

resource "yandex_iam_service_account" "feedback_project_sa" {
  name        = "${local.service_account_name_prefix}-${local.folder_id}"
  description = "For db, object storage, api-gateway and container interaction"
}

resource "yandex_iam_service_account_static_access_key" "feedback_project_sa_static_key" {
  service_account_id = yandex_iam_service_account.feedback_project_sa.id
}

output "feedback_project_sa_id" {
  value = yandex_iam_service_account.feedback_project_sa.id
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.feedback_project_sa_static_key.access_key
}

output "private_key" {
  value = yandex_iam_service_account_static_access_key.feedback_project_sa_static_key.secret_key
  sensitive = true
}
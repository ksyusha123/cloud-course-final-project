resource "yandex_container_registry" "default" {
  name      = "default"
  folder_id = local.folder_id
}

resource "yandex_container_repository" "feedback_api_repository" {
  name = "${yandex_container_registry.default.id}/feedback-api"
}

output "feedback_api_repository_name" {
  value = "cr.yandex/${yandex_container_repository.feedback_api_repository.name}"
}
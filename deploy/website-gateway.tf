locals {
  website_gateway_name = "feedback-website-gateway"
}

resource "yandex_api_gateway" "feedback_website_gateway" {
  name      = local.website_gateway_name
  folder_id = local.folder_id
  spec      = file("../openapi/website.yaml")
}

output "feedback_website_gateway_domain" {
  value = "https://${yandex_api_gateway.feedback_website_gateway.domain}"
}
package functions

import future.keywords.in

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_function_app_flex_consumption"
  resource.change.actions[_] in ["create", "update"]

  # https_only must be explicitly set to true
  not resource.change.after.https_only == true

  msg := sprintf(
    "Function App '%s' must have https_only = true. HTTP traffic is not allowed.",
    [resource.address],
  )
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.actions[_] in ["create", "update"]

  not resource.change.after.https_traffic_only_enabled == true

  msg := sprintf(
    "Storage Account '%s' must have https_traffic_only_enabled = true.",
    [resource.address],
  )
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.actions[_] in ["create", "update"]

  resource.change.after.min_tls_version != "TLS1_2"

  msg := sprintf(
    "Storage Account '%s' must use min_tls_version = 'TLS1_2'. Found: '%s'.",
    [resource.address, resource.change.after.min_tls_version],
  )
}

# Only FC1 is allowed for function app service plans — it is the correct SKU
# for Flex Consumption. Y1, EP1, P1v2, etc. are not permitted.
allowed_function_plan_skus := {"FC1"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_service_plan"
  resource.change.actions[_] in ["create", "update"]

  sku := resource.change.after.sku_name
  not sku in allowed_function_plan_skus

  msg := sprintf(
    "Service Plan '%s' uses SKU '%s'. Only %v is allowed for Function App plans (Flex Consumption).",
    [resource.address, sku, allowed_function_plan_skus],
  )
}

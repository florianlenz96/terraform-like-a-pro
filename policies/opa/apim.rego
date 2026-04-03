package apim

import future.keywords.in

# Only allow cost-effective / non-production-grade SKUs in automated deployments.
# Premium and Standard SKUs must be a conscious decision — open a manual exception.
allowed_skus := {"Consumption_0", "Developer_1"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_api_management"
  resource.change.actions[_] in ["create", "update"]

  sku := resource.change.after.sku_name
  not sku in allowed_skus

  msg := sprintf(
    "APIM resource '%s' uses SKU '%s'. Only %v are allowed. Premium/Standard require a manual approval.",
    [resource.address, sku, allowed_skus],
  )
}

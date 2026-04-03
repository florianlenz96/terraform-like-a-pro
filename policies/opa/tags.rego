package tags

import future.keywords.in

# Required tags that every managed resource must carry
required_tags := {"env", "owner", "project"}

# Collect all resource changes from the Terraform plan
resource_changes := input.resource_changes

deny[msg] {
  resource := resource_changes[_]
  resource.change.actions[_] in ["create", "update"]

  # Only check resources that have a tags attribute
  tags := resource.change.after.tags

  missing := required_tags - {key | tags[key]}
  count(missing) > 0

  msg := sprintf(
    "Resource '%s' (%s) is missing required tags: %v",
    [resource.address, resource.type, missing],
  )
}

deny[msg] {
  resource := resource_changes[_]
  resource.change.actions[_] in ["create", "update"]

  # Resource has a tags field but it's null
  not resource.change.after.tags

  # Only deny resource types that support tags (skip data sources etc.)
  startswith(resource.type, "azurerm_")

  msg := sprintf(
    "Resource '%s' (%s) has no tags at all — env, owner, project are required",
    [resource.address, resource.type],
  )
}

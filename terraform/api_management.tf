resource "azurerm_api_management" "main" {
  name                = "apim-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "ConsumpPremiumV2tion_0" # No hourly charge — great for dev/qa

  tags = var.tags
}

resource "azurerm_api_management_api" "hello" {
  name                  = "hello-api"
  resource_group_name   = azurerm_resource_group.main.name
  api_management_name   = azurerm_api_management.main.name
  revision              = "1"
  display_name          = "Hello API"
  path                  = "hello"
  protocols             = ["https"]
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "get_hello" {
  operation_id        = "get-hello"
  api_name            = azurerm_api_management_api.hello.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.main.name
  display_name        = "Say Hello"
  method              = "GET"
  url_template        = "/"
  description         = "Returns a hello message with environment and timestamp"

  response {
    status_code = 200
    description = "Successful response"
  }
}

# Route APIM requests to the Function App
resource "azurerm_api_management_api_policy" "hello_backend" {
  api_name            = azurerm_api_management_api.hello.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.main.name

  xml_content = <<-XML
    <policies>
      <inbound>
        <base />
        <set-backend-service
          base-url="https://${azurerm_function_app_flex_consumption.api.default_hostname}/api/hello" />
        <rate-limit calls="100" renewal-period="60" />
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
        <set-header name="X-Powered-By" exists-action="delete" />
        <set-header name="X-Environment" exists-action="override">
          <value>${var.environment}</value>
        </set-header>
      </outbound>
      <on-error>
        <base />
      </on-error>
    </policies>
  XML
}

provider "azurerm" {
  features {
  }
}

# Save state in an existing Azure Storage Account
terraform {
  backend "azurerm" {
    resource_group_name  = "cutestcloud-tstate-rg"
    storage_account_name = "cutestcloudtfstate20930"
    container_name       = "tfstate"
    key                  = "elasticsql.tfstate"
  }
}

resource "azurerm_resource_group" "function_app_resource_group" {
  name     = "elastic-sql-function-app"
  location = "West Europe"
}

# Create a Storage Account using LRS
resource "azurerm_storage_account" "function_app_storage_account" {
  name                     = "elasticsql20240327"
  resource_group_name      = azurerm_resource_group.function_app_resource_group.name
  location                 = azurerm_resource_group.function_app_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Service Plan for Linux Function
resource "azurerm_service_plan" "function_app_service_plan" {
  location            = azurerm_resource_group.function_app_resource_group.location
  name                = "elastic-sql-function-app-service-plan"
  resource_group_name = azurerm_resource_group.function_app_resource_group.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Create App Insights for FunctionApp to log to
resource "azurerm_application_insights" "function_app_application_insights" {
  name                = "elastic-sql-function-app-application-insights"
  location            = azurerm_resource_group.function_app_resource_group.location
  resource_group_name = azurerm_resource_group.function_app_resource_group.name
  application_type    = "web"
}

# Create a Function App using a Linux runtime on NET 8 Isolated
resource "azurerm_linux_function_app" "function_app" {
  name                       = "elastic-sql-function-app"
  location                   = azurerm_resource_group.function_app_resource_group.location
  resource_group_name        = azurerm_resource_group.function_app_resource_group.name
  service_plan_id            = azurerm_service_plan.function_app_service_plan.id
  storage_account_name       = azurerm_storage_account.function_app_storage_account.name
  storage_account_access_key = azurerm_storage_account.function_app_storage_account.primary_access_key

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }

    app_scale_limit = 1
  }

  # Create some initial settings for the Environment Variables that are required
  app_settings = {
    "DATABASE_COUNT"                 = var.database_count
    "DB_SERVER"                      = "elastic-sql-server-${var.database_count}-dbs.database.windows.net"
    "DB_PASSWORD"                    = "P@ssw0rd!"
    "ENABLE_LOGGING"                 = false
    "END_DATE"                       = "03/29/2024 12:00:00"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.function_app_application_insights.instrumentation_key
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "elastic-sql-6-databases"
  location = "West Europe"
}

resource "azurerm_resource_group" "resource_group2" {
  name     = "elastic-sql-3-databases"
  location = "West Europe"
}

# resource "azurerm_mssql_server" "sql_server" {
#   name                         = "elastic-sql-server-${var.database_count}-dbs"
#   resource_group_name          = azurerm_resource_group.resource_group2.name
#   location                     = azurerm_resource_group.resource_group2.location
#   version                      = "12.0"
#   administrator_login          = "adminuser"
#   administrator_login_password = "P@ssw0rd!"
# }

# resource "azurerm_mssql_elasticpool" "sql_server_elasticpool" {
#   name                = "sql-elasticpool-${var.database_count}-dbs"
#   resource_group_name = azurerm_resource_group.resource_group2.name
#   location            = azurerm_resource_group.resource_group2.location
#   server_name         = azurerm_mssql_server.sql_server.name
#   max_size_gb         = 10

#   sku {
#     name     = "GP_Gen5"        # Choose the appropriate service tier (Basic, Standard, or Premium)
#     tier     = "GeneralPurpose" # Specify the tier (optional, based on the chosen service tier)
#     family   = "Gen5"
#     capacity = 10
#   }

#   per_database_settings {
#     min_capacity = 0.5 # Minimum vCores per database (optional)
#     max_capacity = 6   # Maximum vCores per database
#   }
# }

# resource "azurerm_mssql_firewall_rule" "sql_server_function_firewall_rule" {
#   name             = "AllowAccessFromAzure"
#   server_id        = azurerm_mssql_server.sql_server.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "0.0.0.0"
# }

# resource "azurerm_mssql_database" "database" {
#   count           = var.database_count
#   name            = "elasticdb-${count.index + 1}"
#   server_id       = azurerm_mssql_server.sql_server.id
#   elastic_pool_id = azurerm_mssql_elasticpool.sql_server_elasticpool.id
# }

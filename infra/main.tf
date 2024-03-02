provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "elastic-sql-${var.database_count}-databases"
  location = "West Europe"
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "elastic-sql-server-${var.database_count}-dbs"
  resource_group_name          = azurerm_resource_group.resource_group.name
  location                     = azurerm_resource_group.resource_group.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "P@ssw0rd!"
}

resource "azurerm_mssql_elasticpool" "sql_server_elasticpool" {
  name                = "sql-elasticpool-${var.database_count}-dbs"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  server_name         = azurerm_mssql_server.sql_server.name
  max_size_gb         = 10
  sku {
    tier     = "GeneralPurpose"
    name     = "GP_Gen5"
    family   = "Gen5"
    capacity = 4
  }
  per_database_settings {
    max_capacity = 3
    min_capacity = 1
  }
}

resource "azurerm_mssql_database" "database" {
  count           = 6
  name            = "elasticdb-${count.index}"
  server_id       = azurerm_mssql_server.sql_server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql_server_elasticpool.id
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  resource_group_name  = var.network.resource_group
  virtual_network_name = var.network.virtual_network
  name                 = var.network.subnet
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm.name}-nic"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ip_configuration {
    name                          = "${var.vm.name}-nic-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "disk" {
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  location             = data.azurerm_resource_group.resource_group.location
  name                 = "${var.vm.name}-data"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8191

}

resource "azurerm_windows_virtual_machine" "vm" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  name = var.vm.name
  size = var.vm.size

  os_disk {
    name                 = "${var.vm.name}-osdisk"
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    # https://github.com/citrix/citrix-cvad-site-deployment-module/blob/02f7b99f8f794d638e1270d4254d536bd09a3f10/terraform/variables.tf#L402-L411
    sku     = "standard-gen2"
    version = "latest"
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username = "saadmin"
  admin_password = "P@ssw0rd1234!"
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachments" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = 1
  caching            = "None"
}

# https://github.com/Shubham27052/terraform-cicd-deploy/blob/107d01a5794e4c6c324f1728bcc9a6423152c70f/db_vm.tf#L87
resource "azurerm_mssql_virtual_machine" "virtualmachine_sqlvm" {
  depends_on                       = [azurerm_virtual_machine_data_disk_attachment.attachments]
  virtual_machine_id               = azurerm_windows_virtual_machine.vm.id
  sql_license_type                 = "PAYG"
  sql_connectivity_update_username = "saadmin"
  sql_connectivity_update_password = "P@ssw0rd1234!"
}

# https://github.com/kpatnayakuni/azure-quickstart-terraform-configuration/blob/4d17b220caa6b70f589fc919e8f65efa7246b52b/101-vm-sql-existing-autobackup-update/main.tf#L17
# resource "azurerm_virtual_machine_extension" "avm-ext-01" {
#   name                       = "SqlIaasExtension"
#   virtual_machine_id         = data.azurerm_virtual_machine.avm-01.id
#   publisher                  = "Microsoft.SqlServer.Management"
#   type                       = "SqlIaaSAgent"
#   type_handler_version       = "1.2"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#   {
#     "AutoTelemetrySettings": {
#     "Region": "${var.location}"
#       },
#     "AutoPatchingSettings": {
#       "PatchCategory": "WindowsMandatoryUpdates",
#       "Enable": true,
#       "DayOfWeek": "Sunday",
#       "MaintenanceWindowStartingHour": "2",
#       "MaintenanceWindowDuration": "60"
#     },
#     "AutoBackupSettings": {
#       "Enable": true,
#       "RetentionPeriod": "${var.sqlAutobackupRetentionPeriod}",
#       "EnableEncryption": true
#     },
#     "KeyVaultCredentialSettings": {
#       "Enable": false,
#       "CredentialName": ""
#     },
#     "ServerConfigurationsManagementSettings": {
#       "SQLConnectivityUpdateSettings": {
#       "ConnectivityType": "Private",
#       "Port": "1433"
#      },
#       "SQLWorkloadTypeUpdateSettings": {
#       "SQLWorkloadType": "GENERAL"
#      },
#       "SQLStorageUpdateSettings": {
#       "DiskCount": "1",
#       "NumberOfColumns": "1",
#       "StartingDeviceID": "2",
#       "DiskConfigurationType": "NEW"
#      },
#      "AdditionalFeaturesServerConfigurations": {
#      "IsRServicesEnabled": "false"
#      }
#     }
#   }
#   SETTINGS
#   protected_settings         = <<PROTECTED_SETTINGS
#   {
#     "StorageUrl": "${data.azurerm_storage_account.asa-01.primary_blob_endpoint}",
#     "StorageAccessKey": "${data.azurerm_storage_account.asa-01.primary_access_key}",
#     "Password": "${var.sqlAutobackupEncryptionPassword}"   
#   }
#   PROTECTED_SETTINGS
# }

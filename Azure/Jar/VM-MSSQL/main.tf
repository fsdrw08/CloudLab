data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  resource_group_name  = var.network.resource_group
  virtual_network_name = var.network.virtual_network
  name                 = var.network.subnet
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.virtual_machine.name}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "${var.virtual_machine.name}-nic-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "disk" {
  for_each = {
    for disk in var.disks : disk.name => disk
  }
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  name                 = each.value.name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb

}

resource "azurerm_windows_virtual_machine" "vm" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  name = var.virtual_machine.name
  size = var.virtual_machine.size

  os_disk {
    name                 = "${var.virtual_machine.name}-Disk-OS"
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

  secure_boot_enabled = true
  admin_username      = "saadmin"
  admin_password      = "P@ssw0rd1234!"
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  for_each = {
    for disk in var.disks : disk.name => disk
  }
  managed_disk_id    = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = each.value.lun
  caching            = "None"
}

# https://github.com/Shubham27052/terraform-cicd-deploy/blob/107d01a5794e4c6c324f1728bcc9a6423152c70f/db_vm.tf#L87
resource "azurerm_mssql_virtual_machine" "mssql_vm" {
  depends_on                       = [azurerm_virtual_machine_data_disk_attachment.disk_attach]
  virtual_machine_id               = azurerm_windows_virtual_machine.vm.id
  sql_license_type                 = "PAYG"
  sql_connectivity_update_username = "saadmin"
  sql_connectivity_update_password = "P@ssw0rd1234!"
}

resource "azurerm_virtual_machine_extension" "vm_ext" {
  for_each = {
    for ext in var.virtual_machine_extensions == null ? [] : var.virtual_machine_extensions : ext.name => ext
  }
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  name                 = each.value.name
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version
  settings             = each.value.settings != null ? each.value.settings : each.value.script == null ? null : <<EOF
  {
     "commandToExecute": "powershell -encodedCommand ${textencodebase64(file(each.value.script), "UTF-16LE")}"
  }
  EOF
  # https://stackoverflow.com/a/67165796
  protected_settings = each.value.protected_settings != null ? each.value.protected_settings : each.value.protected_script == null ? null : <<EOF
  {
     "commandToExecute": "powershell -encodedCommand ${textencodebase64(file(each.value.protected_script), "UTF-16LE")}"
  }
  EOF
}

resource "azurerm_network_security_rule" "nsr" {
  for_each = {
    for rule in var.network_security_rules.rules : rule.name => rule
  }
  resource_group_name         = var.network_security_rules.resource_group_name
  network_security_group_name = var.network_security_rules.network_security_group_name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = azurerm_windows_virtual_machine.vm.private_ip_address
  destination_port_range      = each.value.destination_port_range
}

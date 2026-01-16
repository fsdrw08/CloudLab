# subscription id: <band><region>-shared-001
resource_group_name = "rg-<band><region>-d365-001"

network = {
  resource_group  = "Azure_SharedServices_<region>_Production"
  virtual_network = "Azure_SharedServices_<region>_Production_VNET"
  subnet          = "Azure_SharedServices_<region>_Production_VNET"
}

disks = [
  {
    name                 = "<band><region>D365-P01-Disk-Data1"
    create_option        = "Empty"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 8191
    lun                  = 1
    caching              = "None"
  }
]

virtual_machine = {
  name = "<band><region>D365-P01"
  size = "Standard_E16-8ds_v6"
}

virtual_machine_extensions = [
  {
    # https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows#property-values
    name                 = "Set-NetConnectionProfile"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    script               = "./Attachments/Set-NetConnectionProfile.ps1"
  }
  # {
  #   name  = "Set-MSSQLBackup"
  #   publisher                  = "Microsoft.SqlServer.Management"
  #   type                       = "SqlIaaSAgent"


  # }
]

network_security_rules = {
  resource_group_name         = "Azure_SharedServices_<region>_Management"
  network_security_group_name = "Azure_SharedServices_<region>-nsg"
  rules = [{
    name                   = "Allow-RDP-<band><region>D365-P01"
    priority               = 1048
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_address_prefix  = "VirtualNetwork"
    source_port_range      = "*"
    destination_port_range = "3389"
  }]
}

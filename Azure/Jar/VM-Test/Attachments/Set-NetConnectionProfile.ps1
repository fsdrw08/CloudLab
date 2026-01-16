Set-NetConnectionProfile -Name "Network" -NetworkCategory Private
Enable-NetAdapterBinding -Name "Ethernet 2" -DisplayName "File and Printer Sharing for Microsoft Networks"

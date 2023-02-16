$devs = Get-PnpDevice -Class net |? Status -eq Unknown | Select FriendlyName, InstanceId | where-object FriendlyName -EQ "vmxnet3 Ethernet Adapter"
    $RemoveKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($Devs.InstanceId)"
    Get-Item $RemoveKey | Select-Object -ExpandProperty Property | %{ Remove-ItemProperty -Path $RemoveKey -Name $_ -Verbose }

    bcdedit /emssettings EMSPORT:1 EMSBAUDRATE:115200
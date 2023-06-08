$InnactiveBackup = import-csv '.\Backup Inactive Resources.csv' -Delimiter ";"
$VMData = $InnactiveBackup | Where-Object { $_."Datasource Type" -eq "Microsoft.Compute/virtualMachines" }
$Short = "vm-short-01am-01"
$Medium = "vm-medium-01am-01"
$Long = "vm-long-01am-01"

[datetime]$CurrentDate30 = $(Get-date).AddDays(-30)

foreach ($vm in $vmdata) {
    If ($vm.Policy -eq $Short ) {
        $VmPolicy = $vm.Policy
        Write-Host "---------"
        Write-Host "This server has policy $VmPolicy"
        $vmName = $Vm."Backup Instance"
        Write-Output $vmName
        [datetime]$date = $vm."Latest Recovery Point"
        
        if ($date -lt $CurrentDate30)
        {
        Write-host "Can be removed"
        Write-Output "$vmName;$VmPolicy;$date" | out-file -Append .\backup_to_remove.csv
        }else
            {
                Write-Host "---------"
                Write-Output $Vm."Backup Instance"
                Write-Output "Cannot be removed"
            }
    }
}

[datetime]$CurrentDate90 = $(Get-date).AddDays(-90)

foreach ($vm in $vmdata) {
    If ($vm.Policy -eq $Medium ) {
        $VmPolicy = $vm.Policy
        Write-Host "---------"
        Write-Host "This server has policy $VmPolicy"
        Write-Output $Vm."Backup Instance"
        [datetime]$date = $vm."Latest Recovery Point"
        $vmName = $Vm."Backup Instance"

        

        if ($date -lt $CurrentDate90)
        {
        Write-host "Can be removed"
        Write-Output "$vmName;$VmPolicy;$date" | out-file -Append .\backup_to_remove.csv
        }else
            {
                Write-Host "---------"
                Write-Output $Vm."Backup Instance"
                Write-Output "Cannot be removed"
            }
    }
}


[datetime]$CurrentDate360 = $(Get-date).AddDays(-360)

foreach ($vm in $vmdata) {
    If ($vm.Policy -eq $Long) {
        $VmPolicy = $vm.Policy
        $vmName = $Vm."Backup Instance"
        Write-Host "---------"
        Write-Host "This server has policy $VmPolicy"
        [datetime]$date = $vm."Latest Recovery Point"
        Write-Output ""
        $vmName = $Vm."Backup Instance"
        

        if ($date -lt $CurrentDate360)
        {
        Write-host "Can be removed"
        Write-Output "$vmName;$VmPolicy;$date" | out-file -Append .\backup_to_remove.csv
        }else
            {
                Write-Host "---------"
                Write-Output $Vm."Backup Instance"
                Write-Output "Cannot be removed"
            }
    }
}
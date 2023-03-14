$sub = "s-sis-ch-nonprod-01"
$csv = import-csv "vms.csv"
Select-AzSubscription $sub


Function LogWrite {
    Param ([string]$logstring)
    Add-content $Logfile -value $logstring
}

#Main
$Current_time = Get-date -Format dd-MM-yyyy-hh-mm
$Logfile = "Size-Change-$sub-$Current_time.txt"
LogWrite "$Current_time :Starting Azure VM Size Standard Script"

foreach ($item in $csv) {
    #Checking Variables
    $Server = $item.vm
    $Size = $item.size

    #Doing the change
    $VmProfile = Get-AzVM -Name $Server -status -ErrorAction SilentlyContinue
    if ($VmProfile) {
        $Rg = $VmProfile.ResourceGroupName
        $CurrentSize = $VmProfile.HardwareProfile.VmSize
            
        if ($CurrentSize -ne $Size) {
            #Setting the new size
            $VmProfile.HardwareProfile.VmSize = $Size
            $Update_Vm = Update-AzVM -VM $VmProfile -ResourceGroupName $Rg -ErrorAction SilentlyContinue
            #Writing the log
            $New_Size = (Get-AzVM -Name $VmProfile.name -status).HardwareProfile.VmSize
            [string]$vm = $VmProfile.name
            if ($Update_Vm) {
                LogWrite "$sub;$Rg;$vm;$New_Size"
                Write-host "$Server - $Rg - New Size: $size" -ForegroundColor green
            }
            else {
                LogWrite "$sub;$Rg;$vm;ERROR"
                Write-host "$Server - $Rg - New Size: ERROR" -ForegroundColor yellow
                Write-Warning "Please check $Logfile for the VM's that couldn't be changed"
            }
        }
        else {
            LogWrite "$sub;$Rg;$vm;$Size"
            Write-host "$Server - $Rg - New Size: $size" -ForegroundColor green
        }
                
    }
    else {
        LogWrite "NoSubFound;NoRgFound;$Server;VMnotFound"
        Write-Warning "Please check $Logfile for the VM's that couldn't be changed"
    } 
}
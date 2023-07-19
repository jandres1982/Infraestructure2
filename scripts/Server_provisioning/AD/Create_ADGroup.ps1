Function ADGroup {
    param ($vm, $domain)
    Write-host "Create AD Group"
    $vm = $vm.ToUpper()
    Write-host "Current Server: $vm"
    if ($domain -eq "tstglobal") {
        $KG = $vm.Substring(3, 3)
        $Admin_Head = "_RES_SY_"
        $Admin_Tail = "_ADMIN"
        $Admin_Group = "$KG$Admin_Head$vm$Admin_Tail"
        Write-host "$Admin_Group"
        Write-Host "Please Create the Group Using SIM for tstglobal in advance"
        #New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$hostname Administrators" -Path "OU=RES,OU=Groups_Global,OU=NBI12,DC=tstglobal,DC=schindler,DC=com" -Description "$Hostname Administrators"
    }
    if ($domain -eq "dmz") {
        $KG = $vm.Substring(0, 3)
        $Admin_Head = "_RES_SY_"
        $Admin_Tail = "_ADMIN"
        $Admin_Group = "$KG$Admin_Head$vm$Admin_Tail"
        Write-host "$Admin_Group"
        New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$hostname Administrators" -Path "OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -Description "$Hostname Administrators"
    }
}
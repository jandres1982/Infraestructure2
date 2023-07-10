param([string]$vm,[string]$function,[string]$sub,[string]$domain,$joinuser,$joinpw,$joinuserdmz,$joinpwdmz,$joinusertst,$joinpwtst)

if ($domain -eq "global") {
    $password = $joinpw | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser, $password)
    $vm = $vm.ToUpper()
    $KG = $vm.Substring(0, 3)
    $function = "$KG Windows Server $function"
    $path = ""

    switch ($sub) {
        "s-sis-eu-prod-01" { $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-eu-nonprod-01" { $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-ap-prod-01" { $path = "OU=AP,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-am-prod-01" { $path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-am-nonprod-01" { $path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-ch-nonprod-01" { $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
        "s-sis-ch-prod-01" { $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" }
    }

    New-ADComputer -Name $vm -Path $path -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred

    write-host "$vm and $Function"

}

if ($domain -eq "dmz") {
    $joinpwdmz1 = $joinpwdmz1 | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuserdmz, $joinpwdmz1)
    $vm = $vm.ToUpper()
    $KG = $vm.Substring(0, 3)
    $function = "$KG Windows Server $function"
    #Invoke-Command -ComputerName "shhwsr2306.dmz2.schindler.com" -Credential $cred -ScriptBlock {param($vm,$function,$cred) New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred} -ArgumentList $vm,$function,$cred
    $ScriptingServer = "shhwsr2306.dmz2.schindler.com"
    $parameters = @{
        ComputerName = $ScriptingServer
        Credential   = $cred
        ScriptBlock  = { param($vm, $function, $cred) New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred }
        ArgumentList = $vm, $function, $cred
    }
    Invoke-Command @parameters
}

if ($domain -eq "tstglobal") {
    $joinpwtst = $joinpwtst | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinusertst, $joinpwtst)
    $vm = $vm.ToUpper()
    $KG = $vm.Substring(0, 3)
    $function = "$KG Windows Server $function"
    #Invoke-Command -ComputerName "shhwsr2306.dmz2.schindler.com" -Credential $cred -ScriptBlock {param($vm,$function,$cred) New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred} -ArgumentList $vm,$function,$cred
    $ScriptingServer = "tstshhwsr0326.tstglobal.schindler.com"
    $parameters = @{
        ComputerName = $ScriptingServer
        Credential   = $cred
        ScriptBlock  = { param($vm, $function, $cred) New-ADComputer -Name $vm -Path "OU=EU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred }
        ArgumentList = $vm, $function, $cred
    }
    Invoke-Command @parameters
}

if ($domain -ne "global" -and $domain -ne "dmz" -and $domain -ne $tstglobal) {
    Write-Error "Write a correct Schindler Domain:
    Example: global, dmz or tstglobal"
} else {
    Write-Output "$domain.schindler.com has been selected"
}
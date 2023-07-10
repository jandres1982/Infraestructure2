param([string]$vm, [string]$function, [string]$sub, [string]$domain, $joinuser, $joinpw, $joinuserdmz, $joinpwdmz1, $joinusertst, $joinpwtst)
Write-Output "$domain"
Write-Output "$sub"

switch ($sub) {
    "s-sis-eu-prod-01" {
        $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=EU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-eu-nonprod-01" {
        $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=EU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-ap-prod-01" {
        $path = "OU=AP,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=AP,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-am-prod-01" {
        $path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=AM,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-am-nonprod-01" {
        $path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=AM,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-ch-nonprod-01" {
        $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=EU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
    "s-sis-ch-prod-01" {
        $path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
        $path_tst = "OU=EU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com"
        $path_dmz = "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com"
    }
}

if ($domain -eq "global") {
    $password = $joinpw | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser, $password)
    $vm = $vm.ToUpper()
    $KG = $vm.Substring(0, 3)
    $function = "$KG Windows Server $function"
    $path = ""
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
        ScriptBlock  = {param($vm, $path_dmz, $function, $cred) New-ADComputer -Name $vm -Path $path_dmz -PasswordNotRequired $false -Description $function -credential $cred }
        ArgumentList = $vm, $function, $cred
    }
    Invoke-Command @parameters
    write-host "$vm and $Function"
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
        ScriptBlock  = {param($vm, $path_tst, $function, $cred) New-ADComputer -Name $vm -Path $path_tst -PasswordNotRequired $false -Description $function -credential $cred }
        ArgumentList = $vm, $function, $cred
    }
    Invoke-Command @parameters
    write-host "$vm and $Function"
}

if ($domain -eq "global" -or $domain -eq "dmz" -or $domain -eq $tstglobal) {

    Write-Output "$domain.schindler.com has been selected"
}
else {
    Write-Error "Write a correct Schindler Domain:
    Example: global, dmz or tstglobal"
}
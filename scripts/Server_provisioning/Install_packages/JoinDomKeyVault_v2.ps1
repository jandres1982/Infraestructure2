param([string]$vm, [string]$domain, $joinuser, $joinpw, $joinuserdmz, $joinpwdmz1, $joinusertst, $joinpwtst)
if ($domain -eq "global" -or $domain -eq "tstglobal") {
    Write-Output $domain".schindler.com has been selected"
}
else {
    if ($domain -eq "dmz") {
        Write-Output $domain"2.schindler.com has been selected"
    }
    else {
        Write-Error "Write a correct Schindler Domain:
        Example: global, dmz or tstglobal"
    }
}

if ($domain -eq "global") {
    $domain = "global.schindler.com"
    $joinpw = $joinpw | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser, $joinpw)
    Add-Computer -DomainName $domain -Credential $cred
    Start-Sleep 5
    Restart-Computer -Force
}

if ($domain -eq "dmz") {
    $domain = "dmz2.schindler.com"
    $joinpwdmz1 = $joinpwdmz1 | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuserdmz, $joinpwdmz1)
    Add-Computer -DomainName $domain -Credential $cred
    Start-Sleep 5
    Restart-Computer -Force
}

if ($domain -eq "tstglobal") {
    $domain = "tstglobal.schindler.com"
    $joinpwtst = $joinpwtst | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinusertst, $joinpwtst)
    Add-Computer -DomainName $domain -Credential $cred
    Start-Sleep 5
    Restart-Computer -Force
}
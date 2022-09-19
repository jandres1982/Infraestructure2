#===================================================================================#
#                                                                                   #
# haswell-vms-reporting.ps1                                                         #
# Checks for VMs which require Haswell CPUs (not compliant with IvyBridge EVC)      #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 14.09.2016                                                         #
# Modified Date:                                                                    #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\haswell-vms-reporting.ps1                               #
#                                                                                   #
#===================================================================================#


#####################################################################################
#Specify vCenter name and service account (read-only sufficient)
#---------------------------------------------------------------
$vcname = "vcenterscs.global.schindler.com"
$Username = "SA-PF01-vCSchiRO@itoper.local"

#####################################################################################
#Function to store the vCenter credentials in a securestring PScredential file
#------------------------------------------------------------------------------
function Get-VCCredential {
param( )

#initialize variables
#-------------------
$AdminName = $env:USERNAME
$Path = "D:\Scripts\Swisscom\CheckEVC-Haswell-VM\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "$vcname Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
}


#####################################################################################
# Connect to vCenter
#-------------------
Add-PSSnapin -Name VMware*
$vcname
$Credentials = Get-VCCredential
Connect-VIServer -Server $vcname -Credential $Credentials


#####################################################################################

$vms = get-cluster | get-vm
$haswellvms = $vms | get-view | where-object {$_.Summary.Runtime.FeatureRequirement.key -like "*FMA*"} | select name | sort name

$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To = "michael.barmettler@swisscom.com"
$Subject = "Haswell VMs"
$Body0 = "VMs with Haswell Feature Requirement (EVC issue)"
$Body1 = "----------------------"
$Body2 = $haswellvms | Out-String
$Body3 = "Number of VMs: $($haswellvms.count)"
$Body = "$Body0`n$Body1`n$Body3`n$Body2"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"

#===================================================================================#
#                                                                                   #
# Nubes_Pre-migration-Check.ps1                                                     #
# Powershell script to check VMs to be migrated next day (Pre-Migration checks)     #
# The script queries the cloudinator database. A list of VMs that will be migrated  #
# today, will be generated and checked in vCenterSHH for certain conditions         #
# an email is sent.                                                                 #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 12.07.2016                                                         #
# Modified Date: 12.07.2016                                                         #
# Version: 01.01.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\Nubes_Pre-migration-VMDiskspace.ps1                     #
#                                                                                   #
#===================================================================================#

function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Schindler\Vmware\Nubes_Pre-migration-Check\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "VCenterSCS Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To =  "michael.barmettler@ch.schindler.com" #, "Fabian.Ferreiro@swisscom.com" #Fabian to get the guest storage usage for migration reporting

<#
#######################################################
# Query the Cloudinator Database to get all VMs with migration date
Import-Module SQLPS

$ServerInstance = "10.10.100.112"
$DB = "MigDB"
$SQLUser = "sa-db-schindlerexport"  #Read only permission
$SQLpw = "3d81e118-6859-4d91-8948-f36710de0d91"

$SQLquery =@" 
 
select server_name, CONVERT(varchar,lswave_date,104) as lswave_day, CONVERT(varchar,lswave_date,108) as lswave_time, lswave_site
 from dbo.rhserver as rhs INNER JOIN server as srv
 ON rhs.rhserver_id = srv.server_id
 INNER JOIN lswave as lsw
 ON rhserver_lswave = lsw.lswave_id
 
"@ 
 
$serverlist = invoke-sqlcmd -query $SQLquery -serverinstance $ServerInstance -database $DB -Username $SQLUser -Password $SQLpw

########################################################
# Filter for only VMs migrated Today

$tomorrow = (Get-Date).ToString('dd.MM.yyyy')

$vms =@{}
$vms = $serverlist | Where-Object {$_.lswave_day -like "$tomorrow"}
#>

$vms = Get-view -viewtype virtualmachine


#Query vCenter for every VM
if ($vms){

Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

[System.Collections.ArrayList]$report = $Null
$report = @()


foreach ($vm in $vms.name) {

$gvm = get-vm $vm

######## Guest Used

$GuestDisks = ($gvm | get-vmguest).disks
$GuestDiskSpaceFreeGB = ($GuestDisks | Measure-Object -Property FreeSpaceGB -Sum).sum
$GuestDiskSpaceTotalGB = ($GuestDisks | Measure-Object -Property CapacityGB -Sum).sum
$GuestDiskSpaceUsedGB = [Math]::Round($GuestDiskSpaceTotalGB - $GuestDiskSpaceFreeGB,2)
$UsedSpaceGBVM = [Math]::Round($gvm.usedspaceGB,2)


$body20 = "$vm - Used Space GB (VMware): $UsedSpaceGBVM"
$body30 = "$vm - Used Space GB (Guest): $GuestDiskSpaceUsedGB"

$report.add($body20)
$report.add($body30)

$body50 = "----------------------------------------------"
$report.add($body50)

}


$body40 = $report | Out-string


#Send Mail

$Subject = "Disk-Space Info - VMs migrated Today"
$body10 = "Disk Space Info:"
$body11 = "=================================================="

$Body = "$body10`n$body11`n$body40"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}

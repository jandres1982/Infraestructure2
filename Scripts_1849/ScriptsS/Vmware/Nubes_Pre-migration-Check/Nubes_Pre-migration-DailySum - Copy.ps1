#===================================================================================#
#                                                                                   #
# Nubes_Pre-migration-Check.ps1                                                     #
# Powershell script to check VMs to be migrated next day (Pre-Migration checks)     #
# The script queries the cloudinator database. A list of VMs that will be migrated  #
# next day, will be generated and checked in vCenterSHH for certain conditions      #
# an email is sent.                                                                 #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 12.07.2016                                                         #
# Modified Date: 12.07.2016                                                         #
# Version: 01.01.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\Nubes_Pre-migration-Check.ps1                           #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To = "michael.barmettler@ch.schindler.com" ,"scc.support@ch.schindler.com", "inf.dc.se@ch.schindler.com"


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

$tomorrow = (Get-Date).AddDays(+1).ToString('dd.MM.yyyy')

$vms =@{}
$vms = $serverlist | Where-Object {$_.lswave_day -like "$tomorrow"}



#########################################################
#Query vCenter for every VM
if ($vms){

Add-PSSnapin -Name VMware*
$VIServer = "vcentershh.global.schindler.com"
Connect-VIServer -Server $VIServer


[System.Collections.ArrayList]$report = $Null
$report = @()

foreach ($vm in $vms.server_name) {

$gvm = get-vm $vm

######## Snapshot
$Snapshot = ($gvm | Get-Snapshot).Name
if ($Snapshot){
$body10 = "$vm - WARNING - Snapshot: $Snapshot"
$report.add($body10)
}
else {
$body10 = "$vm - OK - No Snapshot"
$report.add($body10)
}

######## ISO
$ISO = ($gvm | select-object @{Label="ISO"; Expression = {($_ | Get-CDDrive).ISOPath}}).ISO
if ($ISO){
$body20 = "$vm - WARNING - ISO: $ISO"
$report.add($body20)
}
else {
$body20 = "$vm - OK - No ISO"
$report.add($body20)}

######## VMTools
$VMtools = ($gvm).extensiondata.Guest.ToolsStatus
if ($VMtools -like "toolsOk" -or $VMtools -like "toolsOld") {
$body30 = "$vm - OK - VMware Tools Status: $VMtools "
$report.add($body30)
}
else {
$body30 = "$vm - WARNING - Tools: $VMtools"
$report.add($body30)
}

######## SRM Replication
$vmv = Get-View $gvm
$dest = $vmv.config.ExtraConfig | select | where {$_.key -eq “hbr_filter.destination”}
If (($dest) -and ($dest.Value)) {
$body40 = "$vm - WARNING -  VM is replicated with SRM"
$report.add($body40)
}
else {
$body40 = "$vm - OK - No SRM Replication"
$report.add($body40)
}
####### Add line between each Server
$body50 = "----------------------------------------------"
$report.add($body50)
}
$body10 = $report | Out-string


#Send Mail

$Subject = "Pre-Migration Summary for Tomorrow: $tomorrow"
$body00 = "The following VMs will be migrated tomorrow:"
$body01 = "============================================"
$Body = "$body00`n$body01`n$body10"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}

#################################################################### 

$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")

###################################################################

foreach ($sub in $subs)
{

Select-AzSubscription -Subscription "$sub"
az account set --subscription "$sub"

$(Get-AzVM | Select -Property Name, @{Name='OSType'; Expression={$_.StorageProfile.OSDisk.OSType}} | where-object {$_.OsType -eq "Windows"}).name > .\servers_list_$sub.txt

$Servers  = Get-Content "servers_list_$sub.txt"
$Servers  = $Servers | Sort-Object


[int]$num_T = $Servers.Count #Per_variables
[int]$num_R = $num_T #Per_variables
[int]$Per = $null #Per_variables
[int]$Per_1 = $null #Per_variables



foreach ($vm in $Servers)
{

$rg = (get-azvm -Name $vm).ResourceGroupName



##################### Checking VM's Status #################################


If ($(get-azvm -Name $vm -ResourceGroupName $rg -Status).Statuses.displaystatus | where-object {$_ -eq "VM running"})
{

$result = az vm run-command invoke  --command-id RunPowerShellScript --name $vm -g $rg --scripts "c_space_check.ps1"
if ($result)
{
Write-output "$vm,$rg,$sub" >> servers_c_drive_alert.csv
}
else
{
Write-host "Keep working"
}#end invoke result

}#end if for vm running

}#end for each vm

}#end for each sub

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
#$to = "gda_usr_dcff050b-8326-48c9-8bf9-61f8de7e89f0@schindler.com","gdl_usr_7aabcc1e-97e6-4283-9271-c04245556940@cloud.schindler.com"
$to = "antoniovicente.vento@schindler.com"

$Subject = "C Drive Alert for All Windows Azure Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = (get-childitem "*.csv")
$Body = @"
Dear team,

Please find attached the Report for Backup Jobs for Azure Servers.


"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment
param([string]$vm,
    [string]$mac,
    [string]$osversion,
    [string]$templateKgId,
    [string]$function)

$dbname = "server_ldms22_p"
$ServerInstance = "shhwsr1840"
#$templateKgId = "847"

Function CheckTimeZoneAndLocale ([string]$vm) {

    $dic = import-csv '.\TimeZone_Locale_Diccionary.csv' -Delimiter ";"
    $kg = $vm.Substring(0, 3)
    $timezone = $($dic | Where-Object { $_.DeviceName.substring(0, 3) -eq $kg }).TimeZone | select -first 1
    $UserLocale = $($dic | Where-Object { $_.DeviceName.substring(0, 3) -eq $kg }).UserLocale | select -first 1
    $SystemLocale = $($dic | Where-Object { $_.DeviceName.substring(0, 3) -eq $kg }).SystemLocale | select -first 1
    Return $timezone, $UserLocale, $SystemLocale
}

Function SetFunction ([string]$vm, [string]$function) {
    $kg = $vm.ToUpper()
    $kg = $kg.Substring(0, 3)
    $function = "$kg Windows Server $function"
    Return $function
}

$timezone = $(CheckTimeZoneAndLocale -vm $vm)[0]
$UserLocale = $(CheckTimeZoneAndLocale -vm $vm)[1]
$SystemLocale = $(CheckTimeZoneAndLocale -vm $vm)[2]
$function = SetFunction -vm $vm -function $function

Write-Output "$vm"
Write-Output "$mac"
Write-Output "$osversion"
Write-Output "$templateKgId"
Write-Output "$TimeZone"
Write-Output "$UserLocale"
Write-Output "$SystemLocale"

Get-SqlDatabase -ServerInstance $ServerInstance #Using Service Account with permissions

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$epmHost = 'shhwsr2595'#'machine name of EPM server'

$myWS1 = New-WebServiceProxy -uri http://$epmHost/MBSDKService/MsgSDK.asmx?WSDL -UseDefaultCredential

$list = $myWS1.ListMachines("")

if ($list.Devices.DeviceName | Select-String -SimpleMatch $vm) {
    Write-Output "Error, device $vm was found already in the DB"
    Write-Error "Error Server already exist"

    Break
}
else
{ Write-Output "Ok, device was not found" }

#Error return is -1
$NewServerId = $myWS1.AddComputerEx("$vm", "SERVER", "0.0.0.0", "$vm", "$mac", "Provision")

$CheckDuplicate = "0"

While ($CheckDuplicate -ne $null) {
    $GUID = $(New-Guid).ToString().ToUpper()
    $GUID = "{" + "$GUID" + "}"
    $CheckDuplicate = $list.Devices.guid | Select-String -SimpleMatch $GUID
}
$GUID_q = "'" + $GUID + "'"
$vm_q = "'" + $vm + "'"


$QuerySet = "update dbo.computer set deviceid=$GUID_q where devicename=$vm_q"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $dbname -Query $querySet -TrustServerCertificate #Using ServiceAccount With permissions
#$SetData = $myWS1.SetMachineData("$GUID", '"computer"."OS"."Name"', "$osversion")
$myWS1.SetMachineData("$GUID", '"Computer"."Schindler"."OSD"."OSType"', "$osversion")
$myWS1.SetMachineData("$GUID", '"Computer"."Schindler"."OSD"."TimeZone"', "$TimeZone")
$myWS1.SetMachineData("$GUID", '"Computer"."Schindler"."OSD"."UserLocale"', "$UserLocale")
$myWS1.SetMachineData("$GUID", '"Computer"."Schindler"."OSD"."SystemLocale"', "$SystemLocale")
$myWS1.SetMachineData("$GUID", '"Computer"."Schindler"."OSD"."ComputerDescription"', "$function")

$ProvisionTask = $myWS1.CreateProvisioningTask("OSD_AzDevOps_$vm", $templateKgId, "", "")
write-output $ProvisionTask.TaskID
$AddDevice = $myWS1.AddDeviceToScheduledTask($ProvisionTask.TaskID, $vm)
$StartTask = $myWS1.StartTaskNow($ProvisionTask.TaskID, "")
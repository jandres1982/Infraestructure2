param([string]$Server,
[string]$mac)

$server = "zzzwsr0004"
$mac = "005056877888"
$dbuser = "ldmsadmin"
$dbname = "server_ldms22_p"
$ServerInstance = "shhwsr1840"
$file = "D:\Repository\Working\Antonio\LandeskEPM\ApiCall\dbpw.txt"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $dbuser, (Get-Content $file | ConvertTo-SecureString)
$templateKgId = "845"

#Check Authentication and Connection
Get-SqlDatabase -ServerInstance $ServerInstance  -Credential $cred

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$epmHost = 'shhwsr2595'#'machine name of EPM server'

#$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
#$mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)
#$myWS1 = New-WebServiceProxy -uri http://$epmHost/MBSDKService/MsgSDK.asmx?WSDL -Credential $mycreds
$myWS1 = New-WebServiceProxy -uri http://$epmHost/MBSDKService/MsgSDK.asmx?WSDL -UseDefaultCredential

$list = $myWS1.ListMachines("")

if ($list.Devices.DeviceName | Select-String -SimpleMatch $Server)
{
Write-Output "Error, device $server was found already in the DB"
Write-Error "Error Server already exist"

Break
}else
    {Write-Output "Ok, device was not found"}



#Error return is -1
$NewServerId= $myWS1.AddComputerEx("$server","Server","0.0.0.0", "0.0.0.0","$mac","Provision")

$CheckDuplicate = "0"

While ($CheckDuplicate -ne $null)
{
$GUID = $(New-Guid).ToString().ToUpper()
$GUID = "{"+"$GUID"+"}"
#$GUID = "{b8716e11-abd0-483d-91d7-2e921eb1449f}"
$CheckDuplicate = $list.Devices.guid | Select-String -SimpleMatch $GUID
}
$GUID_q = "'"+$GUID+"'"
$server_q = "'"+$server+"'"


$QuerySet = "update dbo.computer set deviceid=$GUID_q where devicename=$Server_q"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $dbname -Credential $cred -Query $querySet -TrustServerCertificate
$SetData = $myWS1.SetMachineData("$GUID", '"computer"."Status"', "test")
$ProvisionTask= $myWS1.CreateProvisioningTask("DevOps_OSD_$server",$templateKgId,"","")
$AddDevice = $myWS1.AddDeviceToScheduledTask($ProvisionTask.TaskID,$server)
$StartTask= $myWS1.StartTaskNow($ProvisionTask.TaskID,"")
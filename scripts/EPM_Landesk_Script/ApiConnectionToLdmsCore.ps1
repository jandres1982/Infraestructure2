####################################################################################
# Description: List Devices to be deleted in a Core when doing a Side-by-Side migration
# Purpose: 
# Autor: David Di Certo
# Date: September 17th 2020
# Prerequisites:
#    - Core server credentials
#
####################################################################################

Clear-Host

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$epmHost1= ''#'machine name of EPM server'
$username1 = ''#'access to epm console'
$password1 = ''

$epmHost2= ''#'machine name of EPM server'
$username2 = ''#'access to epm console'
$password2 = ''

#$secpasswd1 = ConvertTo-SecureString $password1 -AsPlainText -Force
#$mycreds1 = New-Object System.Management.Automation.PSCredential ($username1, $secpasswd1)
#$myWS1 = New-WebServiceProxy -uri http://$epmHost1/MBSDKService/MsgSDK.asmx?WSDL -Credential $mycreds1
$myWS1 = New-WebServiceProxy -uri http://$epmHost1/MBSDKService/MsgSDK.asmx?WSDL -UseDefaultCredential

$list1 = $myWS1.ListMachines("")

#$secpasswd2 = ConvertTo-SecureString $password2 -AsPlainText -Force
#$mycreds2 = New-Object System.Management.Automation.PSCredential ($username2, $secpasswd2)
#$myWS2 = New-WebServiceProxy -uri http://$epmHost2/MBSDKService/MsgSDK.asmx?WSDL -Credential $mycreds2
$myWS2 = New-WebServiceProxy -uri http://$epmHost2/MBSDKService/MsgSDK.asmx?WSDL -UseDefaultCredential

$list2 = $myWS2.ListMachines("")

$res = $list2 | ?{$list1 -notcontains $_}

"Voici la liste des Devices qui sont migrés sur le Core $epmHost2 :" 
foreach ($device2 in $list2.Devices) {
    foreach ($device1 in $list1.Devices) {
        if ($device1.DeviceName -eq $device2.DeviceName){
			$device1.DeviceName
#			$res = $myWS1.DeleteComputerByGUID($device1.GUID)
        }
    }
}




SHH
global.schindler.com/NBI12/Servers/EU


computer add ex
setmachine variables
provisiontask


login
$deviceid= $myWS1.AddComputerEx("SCHINDLER", "COMPUTER", "1.1.1.1", "1.1.1.1","ABCDEF0123", "SN12345678")
$deviceid # 123456
$query= $myWS1.SetMachineData("{514BA67B-122C-5846-9C4E-7C1CEE8197EA}", '"computer"."Status"', "New Value with PW")
$query= $myWS1.CreateProvisioningTask("_tesetmbsdk", $deviceid, "", "")
$id = $query.TaskID
$query= $myWS1.StartTaskNow("$id")

$GUID = function (generate-newGUID)
--- DB ---> computer table, set the parameter on the asset (GUID)


$query= $myWS1.SetMachineData("{514BA67B-122C-5846-9C4E-7C1CEE8197EA}", '"computer"."Status"', "New Value with PW")
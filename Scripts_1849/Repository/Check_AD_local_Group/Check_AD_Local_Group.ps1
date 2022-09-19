

cls
$Servers = gc "D:\Repository\Working\Antonio\Check_AD_Local_Group\Server_List.txt"
$destination = "c$\temp\"
echo "" > "D:\Repository\Working\Antonio\Check_AD_Local_Group\log.txt"
#$Servers = "shhwsr1676"


foreach ($Server in $Servers) {  #<For> each Server Selected in the Server_list.txt file



Write-host ""
Write-host "############################# Server: $Server #########################################" 
Write-host ""


$testSession = New-PSSession -Computer $Server -ErrorAction SilentlyContinue
if(-not($testSession))
{
    Write-Warning "$Server inaccessible!"
    echo "$server , please check it manually" >> "D:\Repository\Working\Antonio\Check_AD_Local_Group\log.txt"
}



Write-host ""



if ((Test-Path -Path "\\$Server\$destination")) { #Verify if is reachable


$Header_ADGroup = "SHH_RES_SY_"
$Tail_ADGroup = "_ADMIN"
$Server_AD_Group = echo "$Header_ADGroup$Server$Tail_ADGroup"
#$AD_Members = Get-ADGroupMember -Identity $Server_AD_Group

$Local_Members = Invoke-command -computername $Server -Scriptblock {Get-LocalGroupMember -Group Administrators}
$check_local_admin = $Local_Members | Select-Object $Server_AD_Group


if (($check_local_admin -eq $null))
{write-host "Check the $Server, local admin is not there"}
else{
Write-host "$server is ok" 
}



Remove-PSSession $testSession
    



}


else {
Write-host "$server no access to the folder"


}
}
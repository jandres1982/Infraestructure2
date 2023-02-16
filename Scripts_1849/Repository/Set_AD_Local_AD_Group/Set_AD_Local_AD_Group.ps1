
#$AD_Members = Get-ADGroupMember -Identity $Server_AD_Group
$server = "shhwsr170X"
Invoke-Command -ComputerName $server -ScriptBlock { 
$server = hostname
$Header_ADGroup = "SHH_RES_SY_"
$Tail_ADGroup = "_ADMIN"
$Server_AD_Group = echo "$Header_ADGroup$Server$Tail_ADGroup"
$GroupObj = [ADSI]”WinNT://localhost/Administrators”
$GroupObj.Add(“WinNT://global/$Server_AD_Group")
}

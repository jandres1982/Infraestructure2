Clear-host

Remove-Item "C:\TEMP\result.txt" -ErrorAction SilentlyContinue
$Server_List = Get-ADComputer -Filter * -SearchBase "OU=SHH,OU=0000,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$Server_name = echo $Server_List.name
$destination = "C$\temp\"



foreach ($Server in $Server_name) {#For each Server Selected in the Computers.txt file
if ((Test-Path -Path \\$server\$destination)) { #Verify if is reachable 

echo ""
echo "Checking $Server"
$Computer_Info = Get-ADComputer $Server
echo "This server is in the Swisscom OU 001:"
echo $Computer_Info.DistinguishedName
echo "Result will be placed it in C:\temp\result.txt"
echo ""

$Header_ADGroup = "SHH_RES_SY_"
$Tail_ADGroup = "_ADMIN"
$Server_AD_Group = echo "$Header_ADGroup$Server$Tail_ADGroup"
$AD_Members = Get-ADGroupMember -Identity $Server_AD_Group

#echo "These are the members from the Local Administrators group"
$Local_Members = Invoke-command -computername $Server -Scriptblock {Get-LocalGroupMember -Group Administrators}



echo "******************************* Start new Server *****************************************" >> "c:\temp\result.txt"
echo "Information for $server" >> "c:\temp\result.txt"
echo "$Server_AD_Group" >> "c:\temp\result.txt"
echo " Members in the AD Server Admin Group" >> "c:\temp\result.txt"
echo "$AD_Members" >> "c:\temp\result.txt"
echo "Administrator Built in Group" >> "c:\temp\result.txt"
echo "Members of the local group" >> "c:\temp\result.txt"
echo "$Local_Members" >> "c:\temp\result.txt"


}
}


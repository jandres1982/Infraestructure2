clear-host
$Servers = gc "D:\Repository\Working\Antonio\Move_Objects_OU\CRD_Test_Computers.txt" #Variable to define Servers to be added.
#$destination = "C$\temp\" #(Where to copy in the server)
  
foreach ($Server in $Servers)
{

#$server = "crdwsr0001"
$Current_OU = Get-ADComputer -identity $server -Property * | Select-String "OU=001"


if ($Current_OU -like '*,OU=001,*')
{
echo "-------------------------------------- Server OU movement --------------------------------------------"
echo "$server is in the $Current_OU"
Move-ADObject -Identity "CN=$Server,OU=CRD,OU=0000,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"  -TargetPath "OU=CRD,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$New_OU = Get-ADComputer -identity $server -Property * | Select-String "OU=000"
echo "The server $Server is in the new OU = $New_OU"

echo "-------------------------------------- Server Moved --------------------------------------------------"

}
else
{
echo = "no 001"
}

}
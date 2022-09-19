
$server_list = gc "D:\Repository\Working\Antonio\Report_Server\Server_List.txt"

$date = get-date -UFormat "%HH_%MM"


foreach ($Server in $Server_List) {  #<For> each Server Selected in the Computers.txt file
# 
# 
# Write-Host "##############################  $Server ###############################################"           
# Write-Host ""
# Write-Host ""
#            if (test-connection -ComputerName $Server -Count 1 -Quiet) 
#            {
#            Write-Host "$Server ping is good!" -ForegroundColor Green
#            }
#}
#


#write-host "$Server"

$KG = $Server.Substring(0,3)

if ($KG -eq "shh")
{


write-output $server


}



}

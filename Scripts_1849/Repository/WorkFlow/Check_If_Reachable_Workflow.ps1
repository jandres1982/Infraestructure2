clear-host
#$Servers = gc "D:\Repository\Working\Antonio\WorkFlow\Server_List.txt"
$destination = "C$\temp\" #(Where to copy in the server)

 
 Workflow Do-Parallel
{


[string[]]$Servers = Get-Content -Path "D:\Repository\Working\Antonio\WorkFlow\Server_List.txt"

Foreach -Parallel ($Server in $Servers)
{


if (test-connection -ComputerName $Server -Count 1 -Quiet)           
           {        
           Write-Output "$Server,OK"

           }
            else
           {

         Write-Output "$Server,NO_OK"
            #Write-Host "$Server is not pingable" -ForegroundColor Yellow
            #Write-Output "$Server, no ping" >> "D:\Repository\Working\Antonio\WorkFlow\Report.txt"
           }


}
}

$Result = Do-Parallel
$Date = date

$Logfile = "D:\Repository\Working\Antonio\WorkFlow\Log_Check_IF_Reachable_Workflow$(Get-Random -Maximum 100).txt"

Function LogWrite
{

   Param ([string]$logstring)

   Add-content $Logfile -value $logstring

  
}

#LogWrite -logstring $Result
Write-Output $Result >> $Logfile





# 
# 
# foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
# 
#
#
#
# 
# 
# Write-Host "##############################  $Computer ###############################################"           
# Write-Host ""
# Write-Host ""
#            if (test-connection -ComputerName $computer -Count 1 -Quiet) 
#            {
#            Write-Host "$computer ping is good!" -ForegroundColor Green
#            Write-Output "$computer, ping OK" >> "D:\Repository\Working\Antonio\Check_If_Reachable\Report.txt"
#            }
#            else
#            {
#            Write-Host "$computer is not pingable" -ForegroundColor Yellow
#            Write-Output "$computer, no ping" >> "D:\Repository\Working\Antonio\Check_If_Reachable\Report.txt"
#            }
#
#            if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable
#            write-host "$destination folder is reachable $Computer" -ForegroundColor Green
#
#            } else {
#            Write-host "$destination folder is not reachable" -ForegroundColor Yellow
#            }
#
#            $Get_Service = Get-service -ComputerName $Computer -name "Zabbix Agent" -ErrorAction SilentlyContinue
#            $Service_Zabbix = $Get_Service.Name
#
#            if ($Service_Zabbix -eq "Zabbix Agent"){
#
#             Write-host "$Computer, has Zabbix Service" -ForegroundColor Green
#
#             }else
#             {
#
#             Write-Host "No Zabbix Agent found in $computer" -ForegroundColor Yellow
#             }
#
#
#             $Get_SEP = Get-service -ComputerName $computer -name "SepMasterService" -ErrorAction SilentlyContinue
#             $Service_SEP = $Get_SEP.Name
#
#             if ($Service_SEP -eq "SepMasterService") { #Comprobación de acceso
#             Write-Host "Server $computer have SEP Installed" -ForegroundColor Green
#             }
#             else
#             {
#             Write-host "$computer has not SEP Installed, please check" -ForegroundColor Yellow
#             }
#
#
#
#
# Write-Host ""
# Write-Host ""
#   }
#   
#
#
#
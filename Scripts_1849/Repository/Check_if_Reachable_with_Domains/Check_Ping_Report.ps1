clear-host
$proc = cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt"
$computers = gc "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)

$date = $(get-date -format yyyy-MM-ddTHH-mm)

$vmObject = [System.Collections.ArrayList]::new() #added ventoa1

foreach ($computer in $computers)
{

    if (test-connection -ComputerName $computer -Count 1 -Quiet)
      {
       $VM = $computer
       $ip = $(Resolve-DnsName $computer).IPAddress
       $Ping = test-connection -ComputerName $computer -Count 1 -Quiet
       
      }
      else
         {
            $computer_dmz2 = $computer + ".dmz2.schindler.com"
            if (test-connection -ComputerName $computer_dmz2 -Count 1 -Quiet)
                {
                $VM = $computer_dmz2
                $ip = $(Resolve-DnsName $computer_dmz2).IPAddress
                $Ping = test-connection -ComputerName $computer_dmz2 -Count 1 -Quiet
             
                }
                else
                   {
                   $computer_tstglobal = $computer + ".tstglobal.schindler.com"
                   if (test-connection -ComputerName $computer_tstglobal -Count 1 -Quiet)
                      {
                      $VM = $computer_tstglobal
                      $ip = $(Resolve-DnsName $computer_tstglobal).IPAddress
                      $Ping = test-connection -ComputerName $computer_tstglobal -Count 1 -Quiet
                      } 
                      else
                          {
                          $VM = $computer
                          $ip = "not found"
                          $ping = "False"
                          } 
                   }
            }

[void]$vmObject.add([PSCustomObject]@{
        Server = $VM
        IP = $ip
        Ping = $ping
        })
                            
}

cd "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\"
$report = 'VMS_'+'_Ping_Report_'+"$date"+'.csv'
$vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report
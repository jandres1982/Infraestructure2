clear-host

$proc = cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt"
#$ID = (Get-Process notepad++).id
#Wait-Process -id $ID -ErrorAction SilentlyContinue

Remove-Item -Path "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"

$computers = gc "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Server_List.txt" #Variable to define Servers to be added.
$destination = "C$\temp\" #(Where to copy in the server)

 foreach ($computer in $computers) {  #<For> each Server Selected in the Computers.txt file
 

            if (test-connection -ComputerName $computer -Count 1 -Quiet)
                {
                Write-Host "$computer, ping is good!" -ForegroundColor Green
                Write-Output "$computer, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"

                }
                else
                {
                    $computer_dmz2 = $computer + ".dmz2.schindler.com"
                    if (test-connection -ComputerName $computer_dmz2 -Count 1 -Quiet)
                    {
                    Write-Host "$computer_dmz2 ping is good!" -ForegroundColor Green
                    Write-Output "$computer_dmz2, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                    }
                      else
                      {
                      $computer_tstglobal = $computer + ".tstglobal.schindler.com"
                      if (test-connection -ComputerName $computer_tstglobal -Count 1 -Quiet)
                      {
                      Write-Host "$computer_tstglobal is pingable" -ForegroundColor Green
                      Write-Output "$computer_tstglobal, ping OK" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                      } 

                                  else {
                                        #Write-host "$destination folder is not reachable" -ForegroundColor Yellow
                                        Write-host "$computer, is not pingable" -ForegroundColor yellow
                                        Write-Output "$computer, NO ping" >> "D:\Repository\Working\Antonio\Check_if_Reachable_with_Domains\Report.txt"
                                        }
                               }
                      }
                      }




 Write-Host ""
 Write-Host ""
   #}
   



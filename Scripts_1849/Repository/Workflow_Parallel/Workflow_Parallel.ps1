$vms = Get-Content "D:\Repository\Working\Antonio\Check_If_Reachable\Server_List.txt"

Workflow test {
    Param ([array]$vms)
    Foreach -parallel ($Server in $vms) {
       


Test-NetConnection $Server -port 80


  
                                        }
              }

Test $vms

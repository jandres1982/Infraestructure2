$server = "SHHWSR0991.global.schindler.com"
$ServerList = Get-Content -Path "C:\Temp\globalservers.txt"
foreach ($server in $ServerList) {
    #invoke-expression "schtasks.exe /query /s $server"
    $Status = ((invoke-expression "schtasks.exe /query /s $server") -like "*SHH_SRV-STATICROUTE01*")
    "Check Task Status for $server $status" 
    if ($status -like "*Could not start*"){
       "Start Service for $server"  
       invoke-expression "schtasks.exe /Run /TN SHH_SRV-STATICROUTE01 /s $server"
       Invoke-Command -ComputerName $server -ScriptBlock {$route = route print ; $route -like "*     6*"}
    }
}

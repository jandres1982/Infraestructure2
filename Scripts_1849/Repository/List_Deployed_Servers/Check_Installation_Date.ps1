clear-host
$Server_List = gc "D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt" #Variable to define Servers to be added.

 foreach ($computer in $Server_List) {  #<For> each Server Selected in the Computers.txt file
  
  echo "$computer installation date is:"

  Invoke-Command -ComputerName $computer -ScriptBlock {([WMI]””).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate)}
  
  echo "" 
}
#Author: Antonio V. Vento Maggio


$Source = "D:\Scripts\Schindler\Execute_CMD_From_a_task\Source\Install.cmd" #Script que vas a copiar en los servidores, si es un ps1 hay que modificar la ejecución del $action
$Destination = "C$\temp" #Donde vas a copiar ese script
$Servers = gc "D:\Scripts\Schindler\Execute_CMD_From_a_task\ServerList.txt" #Listado de servidores


foreach ($Server in $Servers) {

if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

Copy-Item $source -Destination \\$server\$destination -Recurse #Copia del script

$Get_OS = (Get-WMIObject -ComputerName $Server -class win32_operatingsystem).name


if ($Get_OS -match "2008")
{

Invoke-Command -ComputerName $Server -Scriptblock {
ipmo PSScheduledJob
$Date_1 = (get-date).AddSeconds(5)
$Date_exec = $Date_1.ToString('HH:mm:ss') #la fecha obteniendo los datos como argumentos
$Task_2008 = New-JobTrigger -once -at $Date_exec
Register-ScheduledJob -Name "Run CMD" -ScriptBlock {Start-Process cmd -ArgumentList "/c install.cmd" -WorkingDirectory "C:\temp\"}  -Trigger $Task_2008
Get-JobTrigger -name "Run CMD"

}

}
else
{

Invoke-Command -ComputerName $Server -Scriptblock {
    
$taskname = "Run CMD"
$taskdescription = "This is a task to execute a CMD as local system"
$Date_1 = (get-date).AddSeconds(5) #la fecha con 5 segundos más.
$Date_exec = $Date_1.ToString('HH:mm:ss') #la fecha obteniendo los datos como argumentos
$action = New-ScheduledTaskAction -Execute 'C:\temp\install.cmd'
$trigger =  New-ScheduledTaskTrigger  -Once -At $Date_exec
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -Description $taskdescription -Settings $settings -User "System"
   
    }
    }

  } else {

  write-host "\\$computer\$destination is not reachable or does not exist"

  }
  }

  foreach ($Server in $Servers) { #<For> to clean the script file in all servers.
 
  sleep 5 #Put more time if needed to delete the cmd
   Remove-Item "\\$server\$destination\install.cmd" -Recurse #cleaning
   echo ""
   echo ""
   echo "Files Successfully Cleaned"
   Invoke-Command -ComputerName $server -ScriptBlock {$taskname = "Run CMD"
   Unregister-ScheduledTask -TaskName $taskname -confirm:$false
   Remove-JobTrigger -Name "Run CMD" 
   } -ErrorAction SilentlyContinue #elimina la task sin preguntar
  
     
   }

  




#English
#    Copy-Item $source -Destination \\$server\$destination -Recurse
#Invoke-Command -ComputerName $Server -Credential domain\administrator -Scriptblock {
#    
#    
#    $Date_1 = (get-date).AddSeconds(5)
#    $Date_exec = $Date_1.ToString('HH:mm:ss')
#    $action = New-ScheduledTaskAction -Execute {cmd.exe /c "C:\windows\temp\install.cmd"}
#    $trigger = New-ScheduledTaskTrigger -Once -At $Date_exec
#    $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\administrators" -RunLevel Highest
#
#    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Install" -Description "Test"
#    }

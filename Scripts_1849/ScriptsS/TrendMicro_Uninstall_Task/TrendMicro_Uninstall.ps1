$Source = "D:\Scripts\Schindler\TrendMicro_Uninstall_Task\Uninstall.cmd" #Script que vas a copiar en los servidores, si es un ps1 hay que modificar la ejecución del $action
$Destination = "C$\temp\" #Donde vas a copiar ese script
$Servers = gc "D:\Scripts\Schindler\TrendMicro_Uninstall_Task\ServerList.txt" #Listado de servidores

foreach ($Server in $Servers) {

if ((Test-Path -Path \\$Server\$destination)) { #Comprobación de acceso

Copy-Item $source -Destination \\$server\$destination -Recurse #Copia del script

Invoke-Command -ComputerName $server -ScriptBlock {
    c:\temp\Uninstall.cmd /silent
}


#Invoke-Command -ComputerName $Server -Credential test\administrador -Scriptblock { #aqui debes poner tu usuario
#    
#    $Date_1 = (get-date).AddSeconds(5) #la fecha con 5 segundos más.
#    $Date_exec = $Date_1.ToString('HH:mm:ss') #la fecha obteniendo los datos como argumentos
#    $action = New-ScheduledTaskAction -Execute {cmd.exe /c "C:\windows\temp\install.cmd"} #lo que vas a ejecutar en la tarea
#    $trigger = New-ScheduledTaskTrigger -Once -At $Date_exec #Cuando lo harás aqui se ha usado 5 segundos después de que se cree la tarea.
#    $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administradores" -RunLevel Highest #aqui se dice con que tipo de cuenta se ejecutua (BUILTIN la recomendada)
#
#    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Install" -Description "Test" #aqui se crea la tarea remota
#    }

  } else {

  write-host "\\$computer\$destination is not reachable or does not exist"

  }

  }

  foreach ($Server in $Servers) { #<For> to clean the script file in all servers.
#  sleep 2 #Put more time if needed to delete the cmd
   Remove-Item "\\$server\$destination\Uninstall.cmd" -Recurse #cleaning

   echo ""
   echo ""
   echo "Files Successfully Cleaned"
   
#  Invoke-Command -ComputerName $server -ScriptBlock {Unregister-ScheduledTask -TaskName Install -confirm:$false} #elimina la task sin preguntar
     
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

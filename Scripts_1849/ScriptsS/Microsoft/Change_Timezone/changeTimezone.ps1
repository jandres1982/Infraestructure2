<#
File: changeTimezone.ps1
Purpose: change Timezone
Author: Bruno Götschi
Date: 3.04.2017
#>

#Get List of Servers from Flat TXT file
$Servers = Get-Content Servers.txt

#Name the LogFile and Initialize it
$LogFile = ".\Logs\ServerLog.txt"
New-Item $LogFile -type file -force

ForEach ($Server in $Servers) #Loop through each server
{
    $Server
    $Server>>$LogFile

   
    #Add Timezone to "China Standard Time"
    Invoke-Command -ComputerName $Server  -ScriptBlock {C:\WINDOWS\system32\cmd.exe /c tzutil.exe /s "China Standard Time"}

    #Determine if command was successful
    If (!$?) #Add failed
    {
        $Server + " fail: " + $Error[0]>>$LogFile
        "">>$LogFile
    }
    Else #Add succeeded
    {
        $Server + " success">>$LogFile
        "">>$LogFile
        $Server + " success"
    }
}
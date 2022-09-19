<#
File: GlobalGroupAdd2LocalGroup.ps1
Purpose: adding a Domain group to a Local group
Author: Bruno Götschi
Date: 3.04.2017
#>

#Get List of Servers from Flat TXT file
$Servers = Get-Content Servers.txt
#Initaliaze the Domain Group Object
$DomainGroup = [ADSI]"WinNT://global.schindler.com/SHH_RES_SY_SERVER_ABTS-ADMIN,group"

#Name the LogFile and Initialize it
$LogFile = ".\Logs\ServerLog.txt"
New-Item $LogFile -type file -force

ForEach ($Server in $Servers) #Loop through each server
{
    $Server
    $Server>>$LogFile

    #Get Local Group object
    $LocalGroup = [ADSI]"WinNT://$Server/administrators,group"

    #Assign DomainGroup to LocalGroup
    $LocalGroup.Add($DomainGroup.Path)

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
#############################################################################
# Script: Sets Server Location in SACM for Servers in ITSM
# Author: Michael Barmettler
# Date: 14.06.2016
# Comments: Core ID "9" = Qual. Core ID "10" = Prod
#############################################################################

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$sourcefile,
   
   [Parameter(Mandatory=$True, Position=2)]
   [string]$coreid
)

#Specify Error Email Address
$mail = "michael.barmettler@ch.schindler.com"

#Specify LANDesk Location IDs
$bew = "02787d0c-d8cc-4508-ae3b-d5cbeafd16b3" #Bern Wankdorf
$zoi = "128be5e7-afce-4421-9e81-29ca29d9e5c5" #Bern Zollikofen

#Specify the SOAP uri of Tweap
$uri = "http://tweap.global.schindler.com/WebService/WebService.asmx"

#Get Yesterday date to compare it against the data source (migrated yesterday)
$yesterday = (Get-Date).AddDays(-1).ToString('dd.MM.yyyy')

#Import Migration Data and select only VMs where finishdate is equal to yesterday and migrated successfully (status = 1)

try{            
    $migdata = Import-CSV $sourcefile -ErrorAction Stop
}            
catch{             
    #Sendmail that data could not be imported
    Send-MailMessage -To $mail -Subject "NUBES Auto-ITSM-Location - Error" -body "ERROR: Failed to Import Data" -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"
    Exit
}

#Replace Locations with LANDesk Location ID
$migdata | foreach-object {
$_.server_site = $_.server_site.replace("bew",$bew)
$_.server_site = $_.server_site.replace("zoi",$zoi)
}

$systems = $migdata | Where-Object {($_.rhserver_lsend -like "$yesterday*") -and ($_.rhserver_ls -eq "1")}

#Create WebProxy connection to Tweap over SOAP
$proxy = $null                        
try{            
    $proxy = New-WebServiceProxy -Uri $uri -UseDefaultCredential -ErrorAction Stop
}            
catch{             
    Send-MailMessage -To $mail -Subject "NUBES Auto-ITSM-Location - Error" -body "ERROR: Failed to connect to Tweap" -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"
    Exit
}

#Set Location via SOAP for every system
foreach ($system in $systems)
 {
 $setlocation = $proxy.SetLocation($coreid,$system.server_name,$system.server_site)
 #$setlocation
 if ($setlocation.ToString() -match "OK:")
 {
 #OK, Location set:
 Write-Host "$($system.server_name) - $setlocation - $($system.server_site)" 
  } 
 else
 {
 #Failure, Location NOT set:
 $ErrorSetLoc = "$($system.server_name) - $setlocation"
 $Errors +=$ErrorSetLoc
 }
 }
Send-MailMessage -To $mail -Subject "NUBES Auto-ITSM-Location - Error" -body $Errors -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"
 
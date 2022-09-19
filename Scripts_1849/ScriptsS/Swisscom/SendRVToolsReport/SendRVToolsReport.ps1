#===================================================================================#
#                                                                                   #
# SendRVToolsReport.ps1                                                             #
# Powershell Script to send latest RVTools export per Mail                          #
#                                                                                   #
# Author: Erich Niffeler                                                            #
# Creation Date: 21.06.2016                                                         #
# Modified Date: 18.08.2016                                                         #
# Version: 01.00.00                                                                 #
# Update:  18.08.2017 - Added Zip functionality to overcome attachment size issue   #
# Example: $PW = powershell.exe D:\Scripts\Swisscom\SendRVToolsReport.ps1           #
#                                                                                   #
#                                                                                   #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "vcenterscs@ch.schindler.com"
$To = "ServiceManagement.Schindler@swisscom.com","OCC.Bern@swisscom.com","Fabian.Ferreiro@swisscom.com"
$Date = Get-Date -format d
$Subject = "SCS RVTools Exports $Date"
$Path = "D:\Scripts\Schindler\RVTools\Export_SCS\"
$Filename = Get-ChildItem $Path -Name "RVTools_export*" | select -last 1
$Filepath = "$Path$Filename"
$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.

"@

Add-Type -assembly 'System.IO.Compression'
Add-Type -assembly 'System.IO.Compression.FileSystem'

[string]$zipFN = "$path\Zip\$Filename.zip"
[string]$fileToZip = $filepath
[System.IO.Compression.ZipArchive]$ZipFile = [System.IO.Compression.ZipFile]::Open($zipFN, ([System.IO.Compression.ZipArchiveMode]::Update))
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ZipFile, $fileToZip, (Split-Path $fileToZip -Leaf))
$ZipFile.Dispose()


Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $zipFN
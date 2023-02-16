function Generate_report
{
cd "c:\Program Files (x86)\RobWare\RVTools\"
cmd.exe /c '"C:\Program Files (x86)\RobWare\RVTools\rvtools.exe" -u "SA-PF01-vCSchiRO@itoper.local" -p "jsN8pnjFcY8c"  -s "Vcenternubes4"  -c ExportAll2xls -d "D:\Scripts\Schindler\RVTools\Export_PS_Nubes4\Exports" -f Swisscom_Nubes4_Report.xlsx'
}

Generate_report

sleep 10


$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
#$To = "antoniovicente.vento@schindler.com"
$To = "hanspeter.gut@schindler.com","dario.schumacher@schindler.com","antoniovicente.vento@schindler.com","alfonso.marques@schindler.com"
$Date = Get-Date -format "dd-MMM-yyyy_HH-mm"
$Date_file = "-"+$Date+".xlsx"
$Subject = "SwisscomNubes4vCenterReport $Date"
$Path = "D:\Scripts\Schindler\RVTools\Export_PS_Nubes4\Exports\"
$Filename = Get-ChildItem $Path -Name "Swisscom_Nubes4*" | select -Last 1
$Name = $Filename.split(".")[0]
$Name = $Name+$date_file
Move-Item -Path $Path$Filename -Destination $path$Name -Force
$Filename = Get-ChildItem $Path -Name "Swisscom_Nubes4*" | select -Last 1
$Attachment = "$Path$Filename"

$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.

Antonio

"@


Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
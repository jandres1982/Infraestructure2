#Author: Alfonso Marques
#Date: 2019/12/02
#Description: Script to get the folder size per KG in SHHDNA0010

$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('yyyy-MM-dd')

$startFolder = "\\?\UNC\shhdna0010\c$\vol_fs_cifs_shhdna0010_001\odata"
#$colItems = Get-ChildItem -LiteralPath $startFolder -Recurse -File | Measure-Object -Property Length -Sum
#"TOTAL SHHDNA0010 -- " + "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
#"$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1GB) + " GB"

$KGSharedFolder = Get-ChildItem -LiteralPath $startFolder

foreach ($i in $KGSharedFolder){
    $subFolderItems = Get-ChildItem -LiteralPath $i.FullName -Recurse -File -Force | Measure-Object -Property Length -Sum
    $KG = $i.FullName.Substring($i.FullName.Length - 3)
    #$KG + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1GB) + " GB"
    New-Object -TypeName PSCustomObject -Property @{
        Date = $CurrentDate
        FileSize = "{0:N2}" -f ($subFolderItems.sum / 1GB) + " GB"
        FolderName = $KG
    }| Export-Csv -Path "\\shhdna0010\Reports$\KGFolderSize\KGsFolderSizeReport_1849.csv" -NoTypeInformation -Append
} 

#$PSEmailServer = "smtp.eu.schindler.com"
#$From = "SCC-ZAR@schindler.com"
#$To = "alfonso.marques@schindler.com"
#$Date = Get-Date -format d
#$Subject = "KGsFolderSizeReport Updated $Date"
#
#$Body = @"
#Dear All,
#
#KG Folder Size Report is Updated.
#
#This mail is being generated automatically by a scheduled task.
#Please, do not reply.
#
#In case you find any problems, please contact server team.
#"@
#
#Send-MailMessage -From $From -To $To -BCC $BCC1, $BCC2 -Subject $Subject -Body $Body
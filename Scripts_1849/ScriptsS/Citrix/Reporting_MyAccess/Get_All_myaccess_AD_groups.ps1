$File1 = "C:\temp\allgroups1.txt"
$File2 = "D:\Scripts\Schindler\Citrix\Reporting_MyAccess\citrix_groups.txt"

Remove-Item $File2 -Force

Import-Module activedirectory
$_DEV = Get-ADGroupMember "SHH_RES_AP_CAG_MYAUSERSD" | Select-Object name
$QUAL = Get-ADGroupMember "SHH_RES_AP_CAG_MYAUSERSQ" | Select-Object name
$PROD = Get-ADGroupMember "SHH_RES_AP_CAG_MYAUSERSP" | Select-Object name

$All = $_DEV + $QUAL + $PROD | Sort-Object name > $File1

Get-Content $File1 |
    Select -Skip 3 |
    Set-Content "$File1-Temp"
    Move "$File1-Temp" $File1 -Force

(Get-Content $File1) -replace ' ','' > $File2

Remove-Item $File1 -Force
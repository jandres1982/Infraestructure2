#=============================================================================#
#                                                                             #
# TSLicenseCount.ps1                                                          #
# Powershell Script to read out TSExpireDate and msTSManagingLS and           #
# create an HTML file with the output                                         #
# Author: Erich Niffeler                                                      #
# Creation Date: 06.11.2014                                                   #
# Modified Date: 21.01.2015                                                   #
# Version: 01.00.02                                                           #
#                                                                             #
#=============================================================================#
Import-Module ActiveDirectory

Function Get-TSManagingLScount (){
<#
.SYNOPSIS
Function to count the TSManagingLS of user ADObjects with TSExpireDate not older than 90 days 
.DESCRIPTION
Function to count the TSManagingLS of user ADObjects with TSExpireDate not older than 90 days 
.PARAMETER ADObject
No parameters
.EXAMPLE
Get-TSManagingLScount
#>
#$Path = "C:\temp\TSLSReport"
$Path = "D:\Scripts\Schindler\Microsoft\TSLicense\tslsreport"
$TSUserList = @()
$TSUserListexpired = @()
$now = get-date
$Status = ""
#Alarmlevel defines the amount of licenses where $Status switch to critical (2015/01 Licenses purchased 1060)
$Alarmlevel = 900
$ProductID_INFW0145 = '00477-001-9732671-84851'
$ProductID_INFW0146 = '00477-001-2377621-84799'
$ProductID_shhwsrcx0027 = '00477-001-7576037-84512'  
$users = get-aduser -filter * -SearchBase "OU=Users,OU=NBI12,DC=global,DC=schindler,DC=com" -Properties CN,msTSManagingLS,msTSExpireDate
ForEach ($user in $users)
{
    if (($user.msTSManagingLS -eq $ProductID_INFW0145) -or ($user.msTSManagingLS -eq $ProductID_INFW0146) -or ($user.msTSManagingLS -eq $ProductID_shhwsrcx0027))
    {
        #Check if License date is less than 90 days from now
        if ((New-TimeSpan -Start $user.msTSExpireDate -End $now).Days -le 90)
        {
            $TSUserList += $user
        }
        Else
        {
            $TSUserListexpired += $user
        }
    } 
}
$TSUserCount = $TSUserList.count 
$TSUserCountexpired = $TSUserListexpired.count

"**** TSLicense Report of $now ****" | Out-File "$Path.txt"
"**** TS Users with TSLicense not older than 90 days ****" | Out-File "$Path.txt"  -Append
$TSUserCount | Out-File "$Path.txt" -Append
$TSUserList | Select-Object CN,msTSManagingLS,msTSExpireDate  | Out-File "$Path.txt" -Append
" "
"**** TS Users with TSLicense older than 90 days ****" | Out-File "$Path.txt" -Append
$TSUserCountexpired  | Out-File "$Path.txt" -Append
$TSUserListexpired | Select-Object CN,msTSManagingLS,msTSExpireDate  | Out-File "$Path.txt" -Append

if ($TSUserCount -le $Alarmlevel){$Status = "ok"}
else {$Status = "critical"}

$Frag01 = "<h1>TS License Report of $now</h1>"
$Frag02 = "<h2>TS User count (<=90 days): $TSUserCount  - Status: $Status</h2>"
$Frag03 = "<h2>TS User count expired (>90 days): $TSUserCountexpired</h2>"
$Frag04 = $TSUserListexpired | Select-Object CN,msTSManagingLS,msTSExpireDate | Sort CN | ConvertTo-HTML -Fragment 
$Frag05 = "<h3>ProductID_INFW0145 = $ProductID_INFW0145</h3><h3>ProductID_INFW0146 = $ProductID_INFW0146</h3><h3>ProductID_shhwsrcx0027 = $ProductID_shhwsrcx0027</h3>"
$Frag06 = "<h2>TS User accounts expired (>90 days)</h2>"
$Frag07 = "<h2>TS License Server Product ID's</h2>"

$style = @"
<style>
body {
    color:#333333;
    font-family:Calibri,Tahoma;
    font-size: 10pt;
}
h1 {
    text-align:left;
}
h2 {
    border-top:1px solid #666666;
}
h3 {
    color:#333333;
    font-family:Calibri,Tahoma;
    font-size: 11pt;
}
th {
    font-weight:bold;
    color:#eeeeee;
    background-color:#333333;
    cursor:pointer;
}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
.paginate_enabled_next, .paginate_enabled_previous {
    cursor:pointer; 
    border:1px solid #222222; 
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.paginate_disabled_previous, .paginate_disabled_next {
    color:#666666; 
    cursor:pointer;
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.dataTables_info { margin-bottom:4px; }
.sectionheader { cursor:pointer; }
.sectionheader:hover { color:red; }
.grid { width:100% }
.red {
    color:red;
    font-weight:bold;
} 
</style>
"@

$File = ConvertTo-HTML -Head $Style -Body "$Frag01 $Frag07 $Frag05 $Frag02 $Frag03 $Frag06 $Frag04" -Title "<h1>TS License Status</h1>" 
#$File > "$Path.html"
$File | Out-File -Encoding UTF8 "$Path.html"
	
#Invoke-Expression "$Path.html"

}

Get-TSManagingLScount

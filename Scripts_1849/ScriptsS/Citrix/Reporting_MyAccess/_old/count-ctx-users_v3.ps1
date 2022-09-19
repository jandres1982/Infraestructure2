# BE-SCC Michael Barmettler
# 26.03.2014
# This script will count all UNIQUE user-names in the AD-Groups specified in the txt file
# and export it the csv file (append) specified at the end of the script..

Import-Module Activedirectory
$grouplist = Get-Content D:\Scripts\Schindler\Citrix\Reporting\citrix_groups.txt
$array = @()
Foreach ($group in ($grouplist | Get-ADGroup))
{
    $hash=@{Username ='';GroupName=$group.Name}
    $members = $hash.GroupName | Get-ADGroupMember -Recursive -ErrorAction SilentlyContinue
    Foreach($member in $members)
    {
        $properties = $member.SamAccountName | Get-ADUser -Properties SamAccountName
        $hash.Username = $properties.SamAccountName
        $obj = New-Object psObject -Property $hash
        $array += $obj      
    }   
}   
$count = ($array  | select Username -unique).count
$today = (get-date).AddDays(-1).ToString('dd.MM.yyyy')

[Convert]::toString("$today;$count") >>D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_usercount_report.csv
# BE-SCC Michael Barmettler
# 01.04.2014
# This script will report all users in AD-Groups specified in the txt file
# and create reports that will be sent via mail...

Import-Module ActiveDirectory

#General-Parameters
$today = (get-date).ToString('dd.MM.yyyy')
$grouplist = Get-Content D:\Scripts\Schindler\Citrix\Reporting\citrix_groups.txt

# Move and rename files to archive
move-item D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_users_detailed.csv D:\Scripts\Schindler\Citrix\Reporting\Archive\ -ErrorAction SilentlyContinue
rename-item D:\Scripts\Schindler\Citrix\Reporting\Archive\ctx_users_detailed.csv -NewName ("ctx_users_detailed" + $today + ".csv") -ErrorAction SilentlyContinue

# Start with User-Counting and Reporting

$array = @()
Foreach ($group in ($grouplist | Get-ADGroup))
{
    $hash=@{Username ='';GroupName=$group.Name;Company='';Mail='';City='';Description='';msTSManagingLS='';msTSExpireDate='';Enabled=''}
    $members = $hash.GroupName | Get-ADGroupMember -Recursive -ErrorAction SilentlyContinue
    Foreach($member in $members)
    {
        $properties = $member.SamAccountName | Get-ADUser -Properties SamAccountName, Company, Mail, description, Enabled, City, msTSManagingLS, msTSExpireDate
        $hash.Username = $properties.SamAccountName
        $hash.Company = $properties.Company
        $hash.Mail = $properties.Mail
        $hash.City = $properties.City
        $hash.Enabled = $properties.Enabled
        $hash.Description = $properties.description
        $hash.msTSManagingLS = $properties.msTSManagingLS
        $hash.msTSExpireDate = $properties.msTSExpireDate
        $obj = New-Object psObject -Property $hash
        $array += $obj      
    }   
} 
  
#Output Detailed-User-Report to CSV
$array  | select GroupName, Username, Enabled, Company, City, Mail, Description, msTSManagingLS, msTSExpireDate | Export-Csv D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_users_detailed.csv -Encoding Unicode -NoTypeInformation

#Output Count of unique usernames in all groups and export (append) to Usercount CSV
$count = ($array  | select Username -unique).count
[Convert]::toString("$today;$count") >>D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_usercount_report.csv

#Start with Server-Counting
#Total number of Citrix Servers in OU: 0001
$countCTXSRV0001 = (Get-ADComputer -filter * -SearchBase 'OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com').count

#Mail-Parameters

$smtpserver = "smtp.eu.schindler.com"
$from="SHHWSR0025@global.schindler.com"
$to="michael.barmettler@ch.schindler.com", "scc.support@ch.schindler.com", "stefan.epp@ch.schindler.com", "adrian.renggli@ch.schindler.com", "reinhard.weber@ch.schindler.com"
$subject="SCA (old) - Citrix User Report " + $today
$attachment= "D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_usercount_report.csv", "D:\Scripts\Schindler\Citrix\Reporting\_output\ctx_users_detailed.csv", "D:\Scripts\Schindler\Citrix\Reporting\citrix_groups.txt"
$bodyhtml = '<html><body style="background:#FFFFFF"><head><title>Citrix Reporting</title></head>'
			$bodyhtml += '<style type="text/css">'
			$bodyhtml += '#HLine { font-size:20px; font-family:Verdana; font-weight: bold; }'
			$bodyhtml += '#txt { font-size:12px; font-family:Verdana;}'
			$bodyhtml += '</style>'
			$bodyhtml += '<h1 id="HLine">SCA (old) - Citrix User Reporting</h1>'
			$bodyhtml += '<div id="txt"><strong>Date: </strong>' +$today
            $bodyhtml += '<br/><br/><div id="txt"><strong>Number of SCA (old) Users: </strong>' +$count
            $bodyhtml += '<br/><br/>Please check attachments for further details..'
            $bodyhtml += '<br/><br/>Thank You'
            $bodyhtml += '<br/>BE-SCC'
			$bodyhtml += '<br/><div></body></html>'



#Send Mail
send-mailmessage -from $from -to $to -subject $subject -body $bodyhtml -BodyAsHtml -smtpServer $smtpserver -attachments $attachment

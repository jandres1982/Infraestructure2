# BE-SCC Michael Barmettler
# 29.09.2015
# This script will report all users in AD-Groups specified in the txt file
# and create reports that will be sent via mail...

Import-Module ActiveDirectory

#General-Parameters
$today = (get-date).ToString('dd.MM.yyyy')
$grouplist = Get-Content D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\citrix_groups.txt

# Move and rename files to archive
#move-item D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output\ctx_users_detailed.csv D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\Archive\ -ErrorAction SilentlyContinue
move-item D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output2\ctx_users_detailed.csv D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\Archive2\ -ErrorAction SilentlyContinue
#rename-item D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\Archive\ctx_users_detailed.csv -NewName ("ctx_users_detailed" + $today + ".csv") -ErrorAction SilentlyContinue
rename-item D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\Archive2\ctx_users_detailed.csv -NewName ("ctx_users_detailed" + $today + ".csv") -ErrorAction SilentlyContinue

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
$array  | select GroupName, Username, Enabled, Company, City, Mail, Description, msTSManagingLS, msTSExpireDate | Export-Csv D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output\ctx_users_detailed.csv -Encoding Unicode -NoTypeInformation

#Output Count of unique usernames in all groups and export (append) to Usercount CSV
$count = ($array  | select Username -unique).count
[Convert]::toString("$today;$count") >>D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output\ctx_usercount_report.csv

#Total number of Citrix Servers in OU 0001
$countCTXSRV0001 = (Get-ADComputer -filter * -SearchBase 'OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of DEV Citrix Servers in OU 0001
$countCTXSRV0001EDI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of Qual Citrix Servers in OU 0001
$countCTXSRV0001EQI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T3,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T4,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of Prod Citrix Servers in OU 0001
$countCTXSRV0001EPI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T3,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T4,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of Prod Citrix VDI Clients in OU 0001
$countCTXVDI0001EPXDT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XD-T1,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EPXDT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XD-T2,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EPXDT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XD-T3,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EPXDT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XD-T4,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Mail-Parameters

$smtpserver = "smtp.eu.schindler.com"
$from="SHHWSR0025@global.schindler.com"
$to="michael.barmettler@ch.schindler.com"#, "scc.support@ch.schindler.com", "stefan.epp@ch.schindler.com"
$subject="myaccess - Citrix Report - PROD Only" + $today
$attachment= "D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output\ctx_usercount_report.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\_output\ctx_users_detailed.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess_Prod-only\citrix_groups.txt"
$bodyhtml = '<html><body style="background:#FFFFFF"><head><title>myaccess - Citrix Reporting</title></head>'
			$bodyhtml += '<style type="text/css">'
			$bodyhtml += '#HLine { font-size:20px; font-family:Verdana; font-weight: bold; }'
			$bodyhtml += '#txt { font-size:12px; font-family:Verdana;}'
			$bodyhtml += '</style>'
			$bodyhtml += '<h1 id="HLine">myaccess - Citrix Reporting - PROD Only</h1>'
			$bodyhtml += '<div id="txt"><strong>Date: </strong>' +$today
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>myaccess Users Published App and VDI (Prod only): </strong>' +$count
            $bodyhtml += '<br/>(Please check attachments for further details..)'
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>Infrastructure Servers (Published App + VDI): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPI
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers: </strong>'
            $bodyhtml += '<br/><div id="txt">Prod - XA-T1 (GWP): ' +$countCTXSRV0001EPXAT1
            $bodyhtml += '<br/><div id="txt">Prod - XA-T2 (LEEGOO / LBLC / TRD-DEV): ' +$countCTXSRV0001EPXAT2
            $bodyhtml += '<br/><div id="txt">Prod - XA-T3 (Alarmviewer, Rediswin / Simapro, etc): ' +$countCTXSRV0001EPXAT3
            $bodyhtml += '<br/><div id="txt">Prod - XA-T4 (Jumphost): ' +$countCTXSRV0001EPXAT4
            $bodyhtml += '<br/><br/><div id="txt"><strong>VDI Clients: </strong>'
            $bodyhtml += '<br/><div id="txt">Prod - XD-T1 (Personal VDI): ' +$countCTXVDI0001EPXDT1
            $bodyhtml += '<br/><div id="txt">Prod - XD-T2 (Standard VDI): ' +$countCTXVDI0001EPXDT2
            #$bodyhtml += '<br/><div id="txt">Prod - XD-T3 (O365): ' +$countCTXVDI0001EPXDT3
            $bodyhtml += '<br/><br/>Note: This report does not cover maintenance or master image servers / clients (99% powered off / lifecycle-status inactive in ITSM)<br/>'
            $bodyhtml += '<br/>BE-SCC'
			$bodyhtml += '<br/><div></body></html>'



#Send Mail
send-mailmessage -from $from -to $to -subject $subject -body $bodyhtml -BodyAsHtml -smtpServer $smtpserver -attachments $attachment

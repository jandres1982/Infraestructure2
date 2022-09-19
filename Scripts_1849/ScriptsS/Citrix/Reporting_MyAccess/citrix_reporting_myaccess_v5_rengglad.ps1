# BE-SCC Michael Barmettler
# 02.06.2014
# This script will report all users in AD-Groups specified in the txt file
# and create reports that will be sent via mail...

Import-Module ActiveDirectory

#General-Parameters
$today = (get-date).ToString('dd.MM.yyyy')
$grouplist = Get-Content D:\Scripts\Schindler\Citrix\Reporting_myaccess\citrix_groups_rengglad.txt

# Move and rename files to archive
move-item D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output\ctx_users_detailed.csv D:\Scripts\Schindler\Citrix\Reporting_myaccess\Archive\ -ErrorAction SilentlyContinue
rename-item D:\Scripts\Schindler\Citrix\Reporting_myaccess\Archive\ctx_users_detailed.csv -NewName ("ctx_users_detailed" + $today + ".csv") -ErrorAction SilentlyContinue

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
$array  | select GroupName, Username, Enabled, Company, City, Mail, Description, msTSManagingLS, msTSExpireDate | Export-Csv D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output_test\ctx_users_detailed.csv -Encoding Unicode -NoTypeInformation

#Output Count of unique usernames in all groups and export (append) to Usercount CSV
$count = ($array  | select Username -unique).count
[Convert]::toString("$today;$count") >>D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output_test\ctx_usercount_report.csv


#Total number of Citrix Servers in OU 0001
$countCTXSRV0001 = (Get-ADComputer -filter * -SearchBase 'OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of DEV Citrix Servers in OU 0001
$countCTXSRV0001EDI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of DEV Citrix VDI Clients in OU 0001
$countCTXVDI0001EDXDT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XD-T1,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EDXDT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XD-T2,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EDXDT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XD-T3,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EDXDT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XD-T4,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of Qual Citrix Servers in OU 0001
$countCTXSRV0001EQI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T3,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T4,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

#Total number of Qual Citrix VDI Clients in OU 0001
$countCTXVDI0001EQXDT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XD-T1,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EQXDT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XD-T2,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EQXDT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XD-T3,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXVDI0001EQXDT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XD-T4,OU=0001,OU=Computers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count

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
$to="adrian.renggli@schindler.com"
$subject="myaccess - Citrix Report " + $today
$attachment= "D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output_test\ctx_usercount_report.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output_test\ctx_users_detailed.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess\citrix_groups_rengglad.txt"
$bodyhtml = '<html><body style="background:#FFFFFF"><head><title>myaccess - Citrix Reporting</title></head>'
			$bodyhtml += '<style type="text/css">'
			$bodyhtml += '#HLine { font-size:20px; font-family:Verdana; font-weight: bold; }'
			$bodyhtml += '#txt { font-size:12px; font-family:Verdana;}'
			$bodyhtml += '</style>'
			$bodyhtml += '<h1 id="HLine">myaccess - Citrix Reporting</h1>'
			$bodyhtml += '<div id="txt"><strong>Date: </strong>' +$today
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>myaccess Users Published App and VDI: </strong>' +$count
            $bodyhtml += '<br/>(Please check attachments for further details..)'
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>Infrastructure Servers (Published App + VDI): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPI
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXSRV0001EQI
            $bodyhtml += '<br/><div id="txt">Dev:  ' +$countCTXSRV0001EDI
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T1 (GWP):: </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPXAT1
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXSRV0001EQXAT1
            $bodyhtml += '<br/><div id="txt">Dev: ' +$countCTXSRV0001EDXAT1
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T2 (LEEGOO / LBLC / TRD-DEV): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPXAT2
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXSRV0001EQXAT2
            $bodyhtml += '<br/><div id="txt">Dev: ' +$countCTXSRV0001EDXAT2
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T3 (Alarmviewer, Rediswin, Simapro, etc): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPXAT3
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXSRV0001EQXAT3
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T4 (Jumphost): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPXAT4
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXSRV0001EQXAT4
            $bodyhtml += '<br/><br/><div id="txt"><strong>VDI Clients XD-T1 (Personal): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXVDI0001EPXDT1
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXVDI0001EQXDT1
            $bodyhtml += '<br/><div id="txt">Dev: ' +$countCTXVDI0001EDXDT1
            $bodyhtml += '<br/><br/><div id="txt"><strong>VDI Clients XD-T2 (Standard): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXVDI0001EPXDT2
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXVDI0001EQXDT2
            $bodyhtml += '<br/><div id="txt">Dev: ' +$countCTXVDI0001EDXDT2
            $bodyhtml += '<br/><br/><div id="txt"><strong>VDI Clients XD-T3 (O365): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXVDI0001EPXDT3
            $bodyhtml += '<br/><div id="txt">Qual: ' +$countCTXVDI0001EQXDT3
            $bodyhtml += '<br/><div id="txt">Dev: ' +$countCTXVDI0001EDXDT3
            #$bodyhtml += '<br/><div id="txt">Prod - UsecaseT4 (XD-T4): ' +$countCTXVDI0001EPXDT4
            #$bodyhtml += '<br/><div id="txt">Qual - UsecaseT4 (XD-T4): ' +$countCTXVDI0001EQXDT4           
            $bodyhtml += '<br/><br/>Note: This report does not cover maintenance or master image servers / clients (99% powered off / lifecycle-status inactive in ITSM)<br/>'
            $bodyhtml += '<br/>BE-SCC'
			$bodyhtml += '<br/><div></body></html>'



#Send Mail
send-mailmessage -from $from -to $to -subject $subject -body $bodyhtml -BodyAsHtml -smtpServer $smtpserver -attachments $attachment

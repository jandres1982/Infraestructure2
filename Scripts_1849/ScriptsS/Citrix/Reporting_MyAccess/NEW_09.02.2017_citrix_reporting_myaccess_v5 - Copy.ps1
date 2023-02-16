# BE-SCC Michael Barmettler
# 02.06.2014
# This script will report all users in AD-Groups specified in the txt file
# and create reports that will be sent via mail...
# **************************************************************************
# MC-C Adrian Renggli
# 09.02.2017
# Serveral changes done because of new OU structure and VDI replacement
# **************************************************************************

Import-Module ActiveDirectory

#General-Parameters
$today = (get-date).ToString('dd.MM.yyyy')
$grouplist = Get-Content D:\Scripts\Schindler\Citrix\Reporting_myaccess\citrix_groups.txt

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
$array  | select GroupName, Username, Enabled, Company, City, Mail, Description, msTSManagingLS, msTSExpireDate | Export-Csv D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output\ctx_users_detailed.csv -Encoding Unicode -NoTypeInformation

#Output Count of unique usernames in all groups and export (append) to Usercount CSV
$count = ($array  | select Username -unique).count
[Convert]::toString("$today;$count") >>D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output\ctx_usercount_report.csv

#Total number of Citrix Servers in OU 0001
$countCTXSRV0001 = (Get-ADComputer -filter * -SearchBase 'OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001N = (Get-ADComputer -filter * -SearchBase 'OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$CountAllServer = $countCTXSRV0001 + $countCTXSRV0001N

#Total number of DEV Citrix Servers in OU 0001
$countCTXSRV0001EDI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDINEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Infrastructure,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EDI = $countCTXSRV0001EDI + $countCTXSRV0001EDINEW

$countCTXSRV0001EDM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDMNEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-Master,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EDM = $countCTXSRV0001EDM + $countCTXSRV0001EDMNEW

$countCTXSRV0001EDXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT1NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T1,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EDXAT1 = $countCTXSRV0001EDXAT1 + $countCTXSRV0001EDXAT1NEW

$countCTXSRV0001EDXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EDXAT2NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Dev-XA-T2,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EDXAT2 = $countCTXSRV0001EDXAT2 + $countCTXSRV0001EDXAT2NEW

#Total number of Qual Citrix Servers in OU 0001
$countCTXSRV0001EQI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQINEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Infrastructure,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQI = $countCTXSRV0001EQI + $countCTXSRV0001EQINEW

$countCTXSRV0001EQM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQMNEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-Master,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQM = $countCTXSRV0001EQM + $countCTXSRV0001EQMNEW

$countCTXSRV0001EQXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT1NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T1,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQXAT1 = $countCTXSRV0001EQXAT1 + $countCTXSRV0001EQXAT1NEW

$countCTXSRV0001EQXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT2NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T2,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQXAT2 = $countCTXSRV0001EQXAT2 + $countCTXSRV0001EQXAT2NEW

$countCTXSRV0001EQXAT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T3,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT3NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T3,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQXAT3 = $countCTXSRV0001EQXAT3 + $countCTXSRV0001EQXAT3NEW

$countCTXSRV0001EQXAT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T4,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EQXAT4NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Qual-XA-T4,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EQXAT4 = $countCTXSRV0001EQXAT4 + $countCTXSRV0001EQXAT4NEW

#Total number of Prod Citrix Servers in OU 0001
$countCTXSRV0001EPI = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Infrastructure,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPINEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Infrastructure,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPI = $countCTXSRV0001EPI + $countCTXSRV0001EPINEW

$countCTXSRV0001EPM = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Master,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPMNEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-Master,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPM = $countCTXSRV0001EPM + $countCTXSRV0001EPMNEW

$countCTXSRV0001EPXAT1 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T1,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT1NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T1,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPXAT1 = $countCTXSRV0001EPXAT1 + $countCTXSRV0001EPXAT1NEW

$countCTXSRV0001EPXAT2 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T2,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT2NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T2,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPXAT2 = $countCTXSRV0001EPXAT2 + $countCTXSRV0001EPXAT2NEW

$countCTXSRV0001EPXAT3 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T3,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT3NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T3,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPXAT3 = $countCTXSRV0001EPXAT3 + $countCTXSRV0001EPXAT3NEW

$countCTXSRV0001EPXAT4 = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T4,OU=0001,OU=Servers_Global,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$countCTXSRV0001EPXAT4NEW = (Get-ADComputer -filter * -SearchBase 'OU=EMEA-Prod-XA-T4,OU=SHH,OU=0001,OU=001,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com' | Measure-Object).Count
$TotalCTXSRV0001EPXAT4 = $countCTXSRV0001EPXAT4 + $countCTXSRV0001EPXAT4NEW

#Total number of Prod Client VMs
$ClientVMs = Get-Content "D:\Scripts\Schindler\Citrix\Reporting_MyAccess\_output\ClientVMs.txt"

#Mail-Parameters
$smtpserver = "smtp.eu.schindler.com"
$from="SHHWSR0025@global.schindler.com"
#$to="adrian.renggli@schindler.com"
$to="michael.barmettler@ch.schindler.com","inf.myaccess@ch.schindler.com", "stefan.gmuer@schindler.com", "scc.support@ch.schindler.com", "urs.andergassen@ch.schindler.com", "eusebio.rodriguez@schindler.com"
#$to="adrian.renggli@schindler.com","fabian.lingner@schindler.com"
$subject="myaccess - Citrix Report " + $today
$attachment= "D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output\ctx_usercount_report.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess\_output\ctx_users_detailed.csv", "D:\Scripts\Schindler\Citrix\Reporting_myaccess\citrix_groups.txt"
$bodyhtml = '<html><body style="background:#FFFFFF"><head><title>myaccess - Citrix Reporting</title></head>'
			$bodyhtml += '<style type="text/css">'
			$bodyhtml += '#HLine { font-size:20px; font-family:Verdana; font-weight: bold; }'
			$bodyhtml += '#txt { font-size:12px; font-family:Verdana;}'
			$bodyhtml += '</style>'
			$bodyhtml += '<h1 id="HLine">myaccess - Citrix Reporting</h1>'
			$bodyhtml += '<div id="txt"><strong>Date: </strong>' +$today
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>myaccess Users Published App and Client VMs: </strong>' +$count
            $bodyhtml += '<br/>(Please check attachments for further details)'
            $bodyhtml += '<br/>-----------------------------------------'
            $bodyhtml += '<br/><br/><div id="txt"><strong>Infrastructure Servers (Published App): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$TotalCTXSRV0001EPI
            $bodyhtml += '<br/><div id="txt">Qual: ' +$TotalCTXSRV0001EQI
            $bodyhtml += '<br/><div id="txt">Dev:  ' +$TotalCTXSRV0001EDI
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T1 (GWP): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$TotalCTXSRV0001EPXAT1
            $bodyhtml += '<br/><div id="txt">Qual: ' +$TotalCTXSRV0001EQXAT1
            $bodyhtml += '<br/><div id="txt">Dev: ' +$TotalCTXSRV0001EDXAT1
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T2 (LEEGOO / LBLC / TRD-DEV): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$TotalCTXSRV0001EPXAT2
            $bodyhtml += '<br/><div id="txt">Qual: ' +$TotalCTXSRV0001EQXAT2
            $bodyhtml += '<br/><div id="txt">Dev: ' +$TotalCTXSRV0001EDXAT2
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T3 (Alarmviewer, Rediswin, Simapro, CAQ, etc): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$TotalCTXSRV0001EPXAT3
            $bodyhtml += '<br/><div id="txt">Qual: ' +$TotalCTXSRV0001EQXAT3
            $bodyhtml += '<br/><br/><div id="txt"><strong>Published App Servers XA-T4 (Jumphost): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$countCTXSRV0001EPXAT4
            $bodyhtml += '<br/><div id="txt">Qual: ' +$TotalCTXSRV0001EQXAT4
            $bodyhtml += '<br/><br/><div id="txt"><strong>Client VMs (Former VDI): </strong>'
            $bodyhtml += '<br/><div id="txt">Prod: ' +$ClientVMs      
            $bodyhtml += '<br/><br/>Note: This report does not cover maintenance or master image servers / clients (99% powered off / lifecycle-status inactive in ITSM)<br/>'
            $bodyhtml += '<br/>Your myaccess administration team'
			$bodyhtml += '<br/><div></body></html>'

#Send Mail
send-mailmessage -from $from -to $to -subject $subject -body $bodyhtml -BodyAsHtml -smtpServer $smtpserver -attachments $attachment
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$subscription = @("s-sis-eu-nonprod-01", "s-sis-eu-prod-01", "s-sis-am-prod-01", "s-sis-am-nonprod-01", "s-sis-ap-prod-01", "s-sis-ch-prod-01", "s-sis-ch-nonprod-01")

$PeReport = [System.Collections.ArrayList]::new()
Foreach ($sub in $subscription) {
    [int]$i = "0"
    Select-AzSubscription -subscription "$sub"
    $pe = Get-AzPrivateEndpoint
    Foreach ($PeName in $pe) {
        [string]$PeFqdn = $pe[$i].CustomDnsConfigs.Fqdn
        [string]$PeIpAddress = $pe[$i].CustomDnsConfigs[0].IpAddresses
        [void]$PeReport.Add([PSCustomObject]@{
                Name = $pe[$i].name
                Rg = $pe[$i].ResourceGroupName
                Sub = $sub
                ip = $PeIpAddress
                fqdn = $PeFqdn
                Location = $pe[$i].location
                SubnetName = $pe[$i].Subnet.id.split("/")[10]
                VnetName = $pe[$i].Subnet.id.split("/")[8]
            })
        [string]$PeName = $pe[$i].name
        Write-host "We are working on pe $PeName" -ForegroundColor Green
        $i++
        $Report = 'Pe_Report' + "$date" + '.csv'
        $PeReport | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report
    }
}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com","alfonso.marques@schindler.com","nahum.sancho@schindler.com"

$Subject = "Private Endpoint Schindler Report"
$Attachment = $report
$Body = @"
<p>Private Endpoint Report Per Subscription</p>
<p>Please check the file attached,</p>
<p>Thank you,</p>
<p>Kind Regards,</p>
"@
#https://htmled.it/

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -BodyAsHtml

Remove-Item -Path ".\Pe_Report*.csv"
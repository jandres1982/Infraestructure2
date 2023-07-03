Function Send-Mail {
    param ([string]$to, [string]$attachment)
    $PSEmailServer = "smtp.eu.schindler.com"
    $From = "scc-support-zar.es@schindler.com"
    $CC = "antoniovicente.vento@schindler.com"
    $Subject = "Azure Vm Advisor for Cost Reduction"
    $Body = @"
Dear team,

The Azure Resource VM in the list was found to be using more resources than needed generating extra costs.

In this report the VMs use less than 10% CPU in 14 days.

Would you mind to check the recommendations and reduce cost in the attachment file,

Thanks,

Schindler Cloud DevOps Team

"@
    Send-MailMessage -From $From -To $To -Cc $cc -Subject $Subject -Body $Body -Attachments $attachment
}


[int]$i = 0
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$VmCostReduction = [System.Collections.ArrayList]::new()
#$advisor = import-csv .\AdvisorCost_03_Jul_2023.csv -Delimiter ";"
$advisor = import-csv .\AdvisorCost_03_Jul_2023.csv -Delimiter ";"

foreach ($vm in $advisor) {
    $i++
    $SubId = $vm."Subscription ID"
    Select-AzSubscription -SubscriptionId $SubId
    $VmName = $vm."Resource Name"
    $Rg = $vm."Resource Group"
    $vmProfile = Get-azvm -Name $VmName -ResourceGroupName $Rg

    [void]$VmCostReduction.Add([PSCustomObject]@{
            SubId          = $SubId
            Rg             = $Rg
            Vm             = $VmName
            AppOwner       = $vmProfile.tags.applicationowner
            CostSave       = $vm."Potential Annual Retail Cost Savings"
            Recommendation = $vm."Recommended action 1"
        })
    Write-Host "Working on $vmName Number $i"
}
$VmCostReport = 'VmCostReport' + "$date" + '.csv'
$VmCostReduction | Export-Csv $VmCostReport -NoTypeInformation | Select-Object -Skip 1 | Set-Content $VmCostReport
$attachment = $VmCostReport
#$To = "antonio.vicentevento@schindler.com","alfonso.marques@schindler.com"
#Send-mail -to $to -attachment $attachment

### Send to owners:  ###################
$VmCostReportGroup = Import-csv -Delimiter "," -LiteralPath $VmCostReport | group-object AppOwner

Foreach ($AppOwner in $VmCostReportGroup) {
    if ($AppOwner.Group.AppOwner.Count -eq 1) {
        [string]$to = $AppOwner.Group.AppOwner
        $AppOwner.Group | Export-Csv "Report_$to.csv" -NoTypeInformation | Select-Object -Skip 1 | Set-Content 
    }
    else {
        [string]$to = $AppOwner.Group.AppOwner[0]
        $AppOwner.Group | Export-Csv "Report_$to.csv" -NoTypeInformation | Select-Object -Skip 1 | Set-Content 
    }
    $attachment = "Report_$to.csv"
    Write-Output "$attachment"
    #Send-Mail -to $to -attachment $Attachment
    #Only Apply When Advise need to be sent to all owners.
}

#########################################
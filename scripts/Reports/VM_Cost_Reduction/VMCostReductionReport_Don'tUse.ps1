Function Send-Mail {
    param ([string]$to)
    $PSEmailServer = "smtp.eu.schindler.com"
    $From = "scc-support-zar.es@schindler.com"
    $CC = "antoniovicente.vento@schindler.com", "alfonso.marques@schindler.com" 
    #$cc = "javier.cabezudo@schindler.com"
    $Subject = "Azure Vm Advisor for Cost Reduction"
   # $Body = @"
Dear team,

The Azure resource VM in the list was found to be using more resources than needed generating extra costs.

Would you mind to check the recommendations and reduce cost:

SubId:          = 
Rg:             = 
Vm:             = 
AppOwner:       = 
CostSave:       = 
Recommendation: = 

Thanks,

Schindler Cloud DevOps Team

#"@
    Send-MailMessage -From $From -To $To -Cc $cc -Subject $Subject -Body $Body -Attachments "Report_$to.csv"
}


[int]$i = 0
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$VmCostReduction = [System.Collections.ArrayList]::new()
#$advisor = import-csv .\AdvisorCost_03_Jul_2023.csv -Delimiter ";"
$advisor = import-csv .\AdvisorCost_03_Jul_2023_test.csv -Delimiter ";"

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
#$VmCostReportGroup = 'VmCostReportGroup' + "$date" + '.csv'
$VmCostReduction | Export-Csv $VmCostReport -NoTypeInformation | Select-Object -Skip 1 | Set-Content $VmCostReport

#############
$Body1 = "
Dear team, The Azure resource VM in the list was found to be using more resources than needed generating extra costs.
Would you mind to check the recommendations and reduce cost:"


$owners = $VmCostReduction.AppOwner |select-object -unique
foreach ($owner in $owners)
{
    Write-Output "$owner has this VMs:"
    $VmCostReduction | Where-Object {$_.AppOwner -eq $owner}
    foreach ($machine in $VmCostReduction)
    {
        $Body2 = $Body2 + "
        `nSubId: $machine.SubId
        `nRg: $machine.Rg
        `nVm: $machine.Vm
        `nAppOwner: $machine.AppOwner
        `nCostSave: $machine.CostSave
        `nRecommendation:$machine.Recommendation
        "
    }
}

$Body = $body1 + $body2 + "
Thanks,
Schindler Cloud DevOps Team"




############



$VmCostReportGroup = Import-csv -Delimiter "," -LiteralPath $VmCostReport | group-object AppOwner

Foreach ($AppOwner in $VmCostReportGroup)
{
    [string]$to = $AppOwner.Group.AppOwner[0]
    $AppOwner.Group | Export-Csv "Report_$to.csv" -NoTypeInformation | Select-Object -Skip 1 | Set-Content "Report_$to.csv"
    Write-Host "$to"
    Send-Mail -to $to
}
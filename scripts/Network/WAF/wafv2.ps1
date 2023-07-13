$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$date = $(get-date -format yyyy-MM-ddTHH-mm)
###################################################################

$wafPolicyReport = [System.Collections.ArrayList]::new()

foreach ($sub in $subs) {
    az account set --subscription $sub
    Write-Host "Collecting WAf Policy Rules $sub" -BackgroundColor DarkGreen
    Select-AzSubscription -Subscription $sub
    $wafPol = az network application-gateway waf-policy list | convertfrom-json

    foreach ($waf in $wafPol) {
        Write-Output ""
        $wafRg = $waf.resourceGroup
        $wafPolicyName = $waf.Name
        Write-Host "Working on $wafPolicyName"
        $wafPolRule = az network application-gateway waf-policy managed-rule rule-set list --policy-name $wafPolicyName --resource-group $wafRg | convertfrom-json
        #$wafPolRuleSetType = $wafpolrule.managedRuleSets.rulesettype
        [int]$i = "0"
        foreach ($rule in $wafPolRule.managedRuleSets.ruleSetType) {
            if ($wafPolRule.managedRuleSets.ruleSetType.count -gt 1) {
                $RuleSetType = $wafPolRule.managedRuleSets.ruleSetType[$i]
                $ruleSetVersion = $wafPolRule.managedRuleSets.ruleSetVersion[$i]
            }
            else {
                $RuleSetType = $wafPolRule.managedRuleSets.ruleSetType
                $ruleSetVersion = $wafPolRule.managedRuleSets.ruleSetVersion
            }

            Write-Output "$wafPolicyName $RuleSetType $ruleSetVersion"
            $i++
            [void]$wafPolicyReport.Add([PSCustomObject]@{
                    WAF            = $wafPolicyName
                    WAF_RG         = $wafRg
                    WAF_Location   = $waf.Location
                    WAF_Sub        = $sub
                    RuleSetType    = $RuleSetType
                    ruleSetVersion = $ruleSetVersion
                })
        }
    }

}

$report = 'Waf_Report_' + "$date" + '.csv'
$wafPolicyReport | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com"

$Subject = "Waf Policy Rules"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = $report
$Body = @"
Please find attached the report for Waf Policy Manage Rule Set and Version
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment
#$subs ="s-sis-am-nonprod-01" #added ventoa1
#$subs = get-azsubscription -SubscriptionName "$subs" #added ventoa1
#$subs=get-azsubscription
#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")
$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01")
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$security_report = [System.Collections.ArrayList]::new() #added ventoa1

foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub
    Select-AzSubscription -Subscription "$sub"
    $st_accounts = Get-AzStorageAccount
        foreach ($st in $st_accounts)
        {
                $st_account_properties = get-azstorageAccount -Name $st.StorageAccountName -ResourceGroupName $st.ResourceGroupName | Select-Object -Property *
                [void]$security_report.add([PSCustomObject]@{
                Subscription = $sub
                Storage_Account = $st.StorageAccountName
                Resource_Group = $st.ResourceGroupName
                Location = $st.Location
                tls_min_version = $st_account_properties.MinimumTlsVersion
                public_access = $st_account_properties.AllowBlobPublicAccess
                application_owner = $st_account_properties.Tags.applicationowner
                technical_contact = $st_account_properties.Tags.technicalcontact
        })
    }
}
$report = 'St_accounts_'+'_Report_'+"$date"+'.csv'
$security_report | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report
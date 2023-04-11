#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")
$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
###################################################################

$rgs = get-content "rgs.txt"
$cc_new = get-content "tag_cc.txt"
[int]$i = "0"
foreach ($rg in $rgs)
    {#for every RG
        foreach ($sub in $subs)
        {#in every subscription
        Select-AzSubscription -Subscription "$sub"

            if (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)
            {#check if the RG exist in the subscription, and work on it. 
            #Working in the RG
                Write-host "working in $rg"
                $cc = $cc_new[$i]
                $mergedTags = @{"costcenter"="$cc"}
                $rg_name = Get-AzResourceGroup -Name $rg
                Update-AzTag -ResourceId $rg_name.ResourceId -Tag $mergedTags -Operation Merge -ErrorAction SilentlyContinue
            #Working in the resources inside the RG
                $resources = Get-AzResource -ResourceGroupName $rg
                $rid = $resources.ResourceId
                    foreach ($resource_id in $rid)
                        {
                        Update-AzTag -ResourceId $resource_id -Tag $mergedTags -Operation Merge -ErrorAction SilentlyContinue
                        }
            }else
                    {          
                #write-host "can't find this $rg"
                    }
        }
        $i = $i +1
        Write-host ""
        Write-host "$cc was applied to $rg and we are in the iteration $i"
        Write-host ""
}
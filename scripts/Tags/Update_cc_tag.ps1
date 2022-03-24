$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")

###################################################################

$rgs = get-content "rgs.txt"
$cc_new = get-content "tag_cc_new.txt"
[int]$i = "0"
foreach ($rg in $rgs)
    {
        foreach ($sub in $subs)
        {
        Select-AzSubscription -Subscription "$sub"

            if (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)
            {
            Write-host "working in $rg"
            $cc = $cc_new[$i]
            $mergedTags = @{"costcenter"="$cc"}
            $rg_name = Get-AzResourceGroup -Name $rg
            Update-AzTag -ResourceId $rg_name.ResourceId -Tag $mergedTags -Operation Merge    
            }else
                    {          
                #write-host "can't find this $rg"
                    }
        }
        $i = $i +1
        Write-host "$cc and $i and $rg"
}

-----works
############# updating tags for resource group itself ######################
$Rid = Get-AzResourceGroup -Tag @{'kg'="shh"}
$Rid = $rid.ResourceId
$Rg_name = Get-AzResourceGroup -Tag @{'kg'="shh"}
$Rg_name = $Rg_name.ResourceGroupName

foreach ($resource_group_id in $rid)
{
Update-AzTag -ResourceId $resource_group_id -Tag $mergedTags -Operation Merge
}
#######################################


foreach ($rg in $rg_name)
     {
     $resources = Get-AzResource -ResourceGroupName $rg
     $rid = $resources.ResourceId

          foreach ($resource_id in $rid)
          {
          Update-AzTag -ResourceId $resource_id -Tag $mergedTags -Operation Merge
          }
      }



}
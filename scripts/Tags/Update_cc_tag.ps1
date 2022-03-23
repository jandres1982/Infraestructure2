$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")

###################################################################

$rgs = get-content "rg.txt"
$cc_old = get-content "tag_cc_old.txt"
$cc_new = get-content "tag_cc_new.txt"

$mergedTags = @{"cc"="$cc_new"}



foreach ($sub in $subs)
    {
    Select-AzSubscription -Subscription "$sub"
        foreach ($rg in $rgs)
        {
            if (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)
            {
            Write-host "working in $rg"
            }else
                {          
                #write-host "can't find this $rg"
                }
        }
    }

$kg_old= "shh"
$kg_new = "sre"
$mergedTags = @{"kg"="$kg_new"}

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
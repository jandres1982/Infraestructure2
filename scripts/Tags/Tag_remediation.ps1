$Resource_group = Get-content "C:\Users\ventoa1\OneDrive - Schindler\Azure_Devops\Infraestructure\scripts\Tags\rg.txt"

foreach ($rg in $Resource_group) {
    $tags = $(Get-AzResourceGroup -Name $rg).Tags
        $Resource_id = $(Get-AzResource -ResourceGroupName $rg).id
        #$resource_id = "/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/RG-GIS-TEST-SAPHANAPOC-01/providers/Microsoft.Compute/virtualMachines/shhlsr8003"
        foreach ($rid in $Resource_id) {
            Update-AzTag -ResourceId $rid -Tag $Tags -Operation Merge
        }
}
#$tags_resource = $(Get-AzResource -id $resources_id).Tags

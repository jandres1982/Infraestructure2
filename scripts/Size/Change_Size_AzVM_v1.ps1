$sub = "s-sis-eu-nonprod-01"
$csv = import-csv "C:\Users\ventoa1\OneDrive - Schindler\Azure_Devops\Infraestructure\scripts\Size\vms.csv"
select-azSubscription $sub

foreach ($item in $csv)
{
    #Checking Variables
    $Server = $item.vm
    $ResourceGroup = $item.rg
    $Size = $item.size
    Write-host "$Server"
    Write-host "$ResourceGroup"
    Write-host "$Size"

    #Doing the change
    $Server = Get-AzVM -Name $Server -status
    $Server.HardwareProfile.VmSize = $size
    Update-AzVM -VM $Server -ResourceGroupName $ResourceGroup
    
    #Writing the log
    $New_Size = (Get-AzVM -Name $Server.name -status).HardwareProfile.VmSize
    [string]$vm = $Server.name
    Write-Output "$sub;$vm;$New_Size" >> .\AzVmSize.log

}
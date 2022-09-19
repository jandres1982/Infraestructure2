Clear-Host
$Parameters_Base = "D:\Repository\Working\Antonio\Azure\Template_From_Image\parameters_v1.json"
$Template_2019 = "D:\Repository\Working\Antonio\Azure\Template_From_Image\Templates\template_2019.json"
$Template_2016 = "D:\Repository\Working\Antonio\Azure\Template_From_Image\Templates\template_2016.json"


###########################
#Common Variables
$virtualMachineRG = "SDG-TEST"


#########################

$Parameters = ([System.IO.File]::ReadAllText($Parameters_Base)  | ConvertFrom-Json)



######################################################################################
#Changing Azure Parameters for new VM

$hostname = Read-Host "Include the Hostname, Ex: zzzwsr0010"
$location = Read-host "Please Include the location, Ex: westeurope"
$osDiskType = Read-host "Include the osDiskType from: Ex:Premium_LRS https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types"
$size = Read-host "Please include the size of the VM, Ex: Standard_B2s https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
$Win_Ver = Read-host "Please include the OS version EX: 2016 or 2019"


$Parameters.parameters.virtualMachineName.value = "$hostname"
$Parameters.parameters.networkInterfaceName.value = "$hostname`_01"
$Parameters.parameters.location.value = "$location"
$Parameters.parameters.osDiskType.value =  "$osDiskType"
$Parameters.parameters.virtualMachineSize.value = "$size"

$Parameters_Final = "D:\Repository\Working\Antonio\Azure\Template_From_Image\NewServers\parameters_$hostname.json"

$Parameters | ConvertTo-Json | Out-File -FilePath $Parameters_Final -Encoding utf8 -Force




#######################################################################################################
#Running New VM Command

if ($Win_Ver -eq "2019")
{

Connect-AzureRmAccount
New-AzureRmResourceGroupDeployment -ResourceGroupName $virtualMachineRG -TemplateFile "$Template_2019" -TemplateParameterFile "$Parameters_Final"

} else

      { if ($Win_Ver -eq "2016")
        {

        Connect-AzureRmAccount

 
            New-AzureRmResourceGroupDeployment -ResourceGroupName $virtualMachineRG -TemplateFile "$Template_2016" -TemplateParameterFile "$Parameters_Final"
                    
                   
        }
        else
        {Write-host "Please include a correct Windows OS Version" -ForegroundColor Red -BackgroundColor White
        }
} 


#######################################################
#Run in Azure:
#
#
#PS Azure:\> cd $HOME
#PS /home/antonio> ls
#clouddrive  ext.ps1
#PS /home/antonio> ./ext.ps1
#
#Ext.ps1:

#$virtualMachineRG = "SDG-TEST"
#$location = "westeurope"
#$hostname = "zzzwsr0007"
#
#$PublicSettings = @{"workspaceId" = "cb598a59-ed03-4ef4-a57a-416778053ef7"}
#$ProtectedSettings = @{"workspaceKey" = "osGboi116rUm+cGLENECj0jq8Kcels/iE+PEh3r363ZuenQ3MFbsmW259pC4+/Pb9+Zk69HfnButVAJK4blleg=="}
#
#Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
#    -ResourceGroupName $virtualMachineRG `
#    -VMName $hostname `
#    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
#    -ExtensionType "MicrosoftMonitoringAgent" `
#    -TypeHandlerVersion 1.0 `
#    -Settings $PublicSettings `
#    -ProtectedSettings $ProtectedSettings `
#    -Location $location
#
#



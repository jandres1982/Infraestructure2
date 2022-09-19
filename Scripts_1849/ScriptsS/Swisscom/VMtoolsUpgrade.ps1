<#
.Title
 Enabling VMware Tools upgrade at power cycle  >VM’s Options > VMware Tools

.DESCRIPTION
 Setting virtual machines to automatically upgrade VMware Tools at next power-on 
 
.PARAMETER 
   
 
.EXAMPLE
     
 
.NOTES
    FileName:    VMtoolsUpgrade.ps1
    Author:      Bruno Götschi
    Contact:     bruno.goetschi@swisscom.com
    Created:     2017-02-07
    Updated:     2017-02-07
    Version:     1.0.0
#>
# load VMware snapin - if needed
Add-PSSnapin vmware.VimAutomation.core -ErrorAction SilentlyContinue

# connect to the vCenter
connect-viserver -server vcenterscs@ch.schindler.com 

# VM Tools update advanced configuration
# >> Check and upgrade tools during power cycling
#    Import VM table
 
$a = Get-Content "D:\Scripts\Swisscom\vmTools\vm_list.txt"
 foreach ($i in $a){
write-host "Current modified VM" $i
$vm = Get-VM -Name $i | % {Get-View $_.ID}
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
 $vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo
 $vmConfigSpec.Tools.ToolsUpgradePolicy = "upgradeAtPowerCycle"
 $vm.ReconfigVM($vmConfigSpec)
 } ec)
}
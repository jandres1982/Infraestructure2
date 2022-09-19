# Start of Settings 
# Set the number of days to show VMs removed for
$VMsNewRemovedAge = 1
# End of Settings

@(Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType "VmRemovedEvent" | Select @{Name="VMName";Expression={$_.vm.name}}, CreatedTime, UserName, fullFormattedMessage)

$Title = "Removed VMs"
$Header = "VMs Removed (Last $VMsNewRemovedAge Day(s)) : [count]"
$Comments = "The following VMs have been removed/deleted over the last $($VMsNewRemovedAge) days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

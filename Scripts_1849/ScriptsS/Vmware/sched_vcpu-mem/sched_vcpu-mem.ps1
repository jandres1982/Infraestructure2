#    BE-SCC - Michael Barmettler
#    Adjust CPU and / or Memory on a Server. Can be used for Scheduled Tasks
#    Version 0.9 / 2016/06/10

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$vcenter,

   [Parameter(Mandatory=$True,Position=2)]
   [string]$vm,

   [Parameter(Mandatory=$False,Position=3)]
   [int32]$vcputotal,

   [Parameter(Mandatory=$False,Position=4)]
   [int32]$corespersocket,
   
   [Parameter(Mandatory=$False, Position=5)]
   [Decimal]$vmem,

   [Parameter(Mandatory=$False, Position=6)]
   [string]$mail
)

#add VMware PowerCli Snapins and connect to vCenter
add-pssnapin -Name vmware* -ErrorAction SilentlyContinue
connect-viserver $vcenter

$getvm = get-vm $vm

#Shutdown VM for CPU / Memory adjustment
$getvm | Stop-VMguest –Confirm:$False

#wait 60 sec to be sure the VM has been shutdown
start-sleep -s 60

#set the CPU
if ($vcputotal -and $corespersocket) {
$spec = new-object -typename VMware.VIM.virtualmachineconfigspec -property @{'numcorespersocket'=$corespersocket;'numCPUs'=$vcputotal}
(Get-VM –Name $vm).ExtensionData.ReconfigVM_Task($spec)
}

#set the Memory
if ($vmem) {
$getvm | set-vm -memoryGB $vmem –Confirm:$False
}

#Start the VM after the reconfig
$getvm | start-VM

#Restart VM only in case CPU were modified
if ($vcputotal) {
start-sleep -s 60
$getvm | restart-vmguest -Confirm:$False
}

#Get Latest Config
$lconf = get-vm $vm

#Send Mail
if ($mail) {
start-sleep -s 60
Send-MailMessage -To $mail -Subject "$vm - Virtual hardware resources adjusted" -body "Current configuration: $($lconf.numcpu) vCPU. $($lconf.MemoryGB)GB Memory. $($lconf.powerstate)." -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"
}
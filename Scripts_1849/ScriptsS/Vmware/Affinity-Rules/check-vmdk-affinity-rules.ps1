##############################################################################
##
## Checks and verify VMware VMDK Anti-Affinity rules set by BE-SCC LX Team
##
## 20141024 hammerar, initial version
## 20141118 hammerar, readout complete
## 20141202 hammerar, ignore VMs with "Clone" in the Hostname
## 20141223 hammerar, fix empty email issue
## 20150105 hammerar, fix empty email - 2nd attempt
##############################################################################

$myBody = [System.Collections.ArrayList]@()

Function SendEmail() {

   $mailto = "inf.dc.se@ch.schindler.com"
   $mailfrom = "inf.dc.se@ch.schindler.com"
   $mailsubject = "VMware VMDK (Anti-)Affinity Rules read out"
   $mailbody = ""
   
   # bail out if nothing to send
   if ( $myBody -eq $null -or $myBody.Count -eq 0 ) {   
      return
   }
   
   #write-host $myBody.Count
   #write-host $myBody
   
   For( $i = 0; $i -lt $myBody.Count; $i++) {

      $mailbody = $mailbody + $myBody[$i] + [Environment]::NewLine
   }    
   
   $mailbody = $mailbody + [Environment]::NewLine
   $mailbody = $mailbody + "[sent by Windows Scripting Host shhhwsr0025]" + [Environment]::NewLine
      
   $smtpserver = "smtp.eu.schindler.com"   

   send-mailmessage -to $mailto -from $mailfrom -subject $mailsubject -smtpserver $smtpserver -body $mailbody
}

#############################################################################
$myvcenter = "vcentershh.global.schindler.com"

# include all VMware cmdlets
# asnp vmware*
add-pssnapin -Name vmware* -ErrorAction SilentlyContinue

# connect to vCenter -> fill out popup to gain access
$null = connect-viserver -server $myvcenter

##############################################################################

# walk through all vmware guests
#ForEach( $vmguest in Get-View -ViewType VirtualMachine -Filter @{"Name" = "infl02"} | Sort Name ) { 
#ForEach( $vmguest in Get-View -ViewType VirtualMachine -Filter @{"Name" = "infl021"} | Sort Name ) { 
#ForEach( $vmguest in Get-View -ViewType VirtualMachine -Filter @{"Name" = "infl0234"} | Sort Name ) { 
ForEach( $vmguest in Get-View -ViewType VirtualMachine | Sort Name ) { 
   
    # vmware guest analsis
    if ( $vmguest.Summary.Config.GuestFullName -like "*inux*" -or
         $vmguest.Summary.Config.GuestFullName -like "*centos*" ) {
             
        # skip list
        if ( $vmguest.Name -like "*clone*" -or
             $vmguest.Name -like "clone*" -or
             $vmguest.Name -like "*clone") {
             
           write-host "VM Name:" $vmguest.Name "skipped because <clone> tag detected"
           continue
        }      
             
        $DiskCount = 0  
        $StoreCount = 0     
             
        ForEach( $vmdisk in Get-Harddisk -VM $vmguest.Name) {   $DiskCount++  }        
        ForEach( $vmstore in Get-Datastore -VM $vmguest.Name) { $StoreCount++ }
        
        $HACluster = get-Cluster -VM $vmguest.Name
        if ( $HACluster -eq $null -or $HACluster.name -eq $null) {
           # use the ESXi hostname instead of Cluster Name
           $HACluster = Get-VMHost -VM $vmguest.Name
        }        
        
        write-host "VM Name:" $vmguest.Name "on" $HACluster.name " - OS:" $vmguest.Summary.Config.GuestFullName " - VMDKs:" $DiskCount " - Datastores:" $StoreCount

        #SAP running vmware guest
        # 2x VMDK for OS
        # min. 3x VMDK for SAP
        if ( $DiskCount -ge 5) {
        
           # does it use at least 3 datastores?
           if ( $StoreCount -lt 3) {
              # no
              write-host "  Datastore usage is suspicious - check proper VMDK to Datastore distribution"              
              $null = $myBody.add( "")
              $null = $myBody.add( $vmguest.Name + " on " + $HACluster.name + " Datastore usage is suspicious - check proper VMDK to Datastore distribution")
            } else {
              continue
            }
        } else {
          continue
        }       
                     
        $DiskCount = 0                       
        # Get-Harddisk returns type "HardDisk"
        ForEach ($vmdisk in Get-Harddisk -VM $vmguest.Name ) {
        
            $DiskCap = [math]::Round($vmdisk.CapacityGB)
            $DiskFCap = "{0,6:N0}" -f $DiskCap
            $DiskName = $vmdisk.Filename
            
            write-host "  - Disk" $DiskCount "[" $DiskFCap "] -" $DiskName
            $null = $myBody.add( "- Disk " + $DiskCount + "[" + $DiskFCap + "] -" + $DiskName)
                    
            $DiskCount++            
        } # ForEach      
                
    } # if    

} # ForEach
##############################################################################

#$myBody
SendEmail

disconnect-VIServer * -Confirm:$false
##### EOF ####################################################################

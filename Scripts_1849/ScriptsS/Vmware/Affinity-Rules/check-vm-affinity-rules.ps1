##############################################################################
##
## Checks and verify VMware VM Anti-Affinity rules set by BE-SCC LX Team
##
## 20141024 hammerar, initial version
## 20141107 hammerar, rules to check added
## 20141117 hammerar, ready for going live
##############################################################################

$myRules = [System.Collections.ArrayList]@()
$null = $myRules.Add( "DMZ_Cluster - PX2 - PX4 Anti-Affinity Rule")
$null = $myRules.Add( "PX2 - PX4 Anti-Affinity Rule - infl0415")
$null = $myRules.Add( "PX2 - PX4 Anti-Affinity Rule - infl0785")
#$null = $myRules.Add( "Email - Test - Rules")

Function CheckAndSetRule( [string] $param) {

   For( $i = 0; $i -lt $myRules.Count; $i++) {

      If ( $myRules[$i] -like $param) {
      
         write-host "-- hit found <$param> --"
         # rule found - mark or remove it
         $myRules.Remove( $param)       
      }
   }
}

Function CheckAndNotifyRule() {
   
   For( $i = 0; $i -lt $myRules.Count; $i++) {

      write-host "-- " $myRules[$i] " --"       
   }   
}

Function SendEmail() {

   $mailto = "inf.dc.se@ch.schindler.com"
   $mailfrom = "inf.dc.se@ch.schindler.com"
   $mailsubject = "VMware VM (Anti-)Affinity Rules violated - fix it"
   $mailbody = ""
   
   For( $i = 0; $i -lt $myRules.Count; $i++) {

      $mailbody = $mailbody + $myRules[$i] + [Environment]::NewLine
   }    
   
   $mailbody = $mailbody + [Environment]::NewLine
   $mailbody = $mailbody + "[sent by Windows Scripting Host shhhwsr0025]" + [Environment]::NewLine
      
   $smtpserver = "smtp.eu.schindler.com"   

   send-mailmessage -to $mailto -from $mailfrom -subject $mailsubject -smtpserver $smtpserver -body $mailbody
}

# Debug
#CheckAndNotifyRule

# http://blogs.msdn.com/b/powershell/archive/2007/01/23/array-literals-in-powershell.aspx
# http://stackoverflow.com/questions/9397137/powershell-multidimensional-arrays
#############################################################################
$myvcenter = "vcentershh.global.schindler.com"

# include all VMware cmdlets
# asnp vmware*
add-pssnapin -Name vmware* -ErrorAction SilentlyContinue

# connect to vCenter -> fill out popup to gain access
$null = connect-viserver -server $myvcenter

##############################################################################

# walk through all clusters
ForEach( $cluster in Get-View -ViewType ClusterComputeResource -Property Name) {

    write-host "======================================================"
    write-host "Cluster : " $cluster.Name

    $drsrules = get-drsrule -cluster $cluster.Name
    if ( $drsrules) {              
      ForEach ( $drsrule in $drsrules) {
         write-host "-------------------------------------"
         write-host "Rule   : " $drsrule.Name
         write-host "Enable : " $drsrule.Enabled

         CheckAndSetRule( $cluster.Name + " - " + $drsrule.Name)

         # write-host $mydrsrule.VMIds
         ForEach( $vmid in $drsrule.VMIds ) { 

            $vmname = Get-VM -Id $vmid
            write-host "Host   : " $vmname
            
            CheckAndSetRule( $drsrule.Name + " - " + $vmname)
         } # ForEach ( $vmid
       } # ForEach ( $drsrule
     } # if  
} # ForEach

# Debug
#CheckAndNotifyRule

if ($myRules) {

   # some rules have not been cleaned - inform admins
   SendEmail
   
   write-host ""
   write-host "Unmatched rules found - check failed - emails sent"  
      
} else {
   write-host ""
   write-host "All rules matched - check passed"   
}

##############################################################################

disconnect-VIServer * -Confirm:$false
##### EOF ####################################################################

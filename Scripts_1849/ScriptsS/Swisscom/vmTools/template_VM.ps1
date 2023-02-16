<#
 
.DESCRIPTION
 
 
.PARAMETER 
   
 
.EXAMPLE
     
 
.NOTES
    FileName:    Template_VM.ps1
    Author:      Bruno Götschi
    Contact:     bruno.goetschi@swisscom.com
    Created:     2017-02-07
    Updated:     2017-02-07
    Version:     1.0.0
#>
# load VMware snapin - if needed
Add-PSSnapin vmware.VimAutomation.core -ErrorAction SilentlyContinue

# connect to the vCenter
connect-viserver -server <VirtualCenter Server IP address> -user <VirtualCenter User> -password <VirtualCenter password>
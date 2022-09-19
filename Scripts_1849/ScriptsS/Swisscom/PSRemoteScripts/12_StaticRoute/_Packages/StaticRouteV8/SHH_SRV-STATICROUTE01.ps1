#    Author: Michael Barmettler - Swisscom INI-ON-RCG-SDC
#    Version 3.7 - 2017/05/02
#    Description: Add Static Route to a Server based on a comparison table.
#    The script will query the servers default gateway.
#    Based on the Servers Default-Gateway, we know which Destination Gateway to point the route to the HDB.
#    The Route is not set Permanent (-p). Thus, we can add the script as a Startup Script and the route is not permantent if not extecuted every boot.
#    
#-------------------------------------------------------------------------------

#Specify all possible gateway combinations (Comparision List). 
#-------------------------------------------------------------------------------
$GWTable=@{
"10.10.74.1"="10.10.74.254";           #Vlan120   
"10.10.64.1"="10.10.64.254";           #Vlan1301  
"10.10.160.1"="10.10.160.254";         #Vlan1314  
"10.10.76.1"="10.10.76.254";           #Vlan122   
"10.10.78.1"="10.10.78.254";           #Vlan160   
"10.10.79.1"="10.10.79.254";           #Vlan180   
"10.10.65.1"="10.10.65.254";           #Vlan1302  
"10.10.67.1"="10.10.67.254";           #Vlan1304  
"10.10.66.1"="10.10.66.254";           #Vlan1303  
"136.238.5.133"="136.238.5.254";       #Vlan1     
"136.238.83.1"="136.238.83.254";       #Vlan4     
"10.10.24.1"="10.10.27.254";           #Vlan8     
"10.10.58.1"="10.10.59.254";           #Vlan102   
"10.10.60.1"="10.10.61.254";           #Vlan103   
"10.10.62.1"="10.10.63.254";           #Vlan104
"136.238.80.1"="136.238.80.217";       #Vlan111   
"10.10.75.1"="10.10.75.254";           #Vlan121   
"10.10.80.1"="10.10.80.254";           #Vlan150   
"10.10.81.1"="10.10.81.254";           #Vlan175   
"136.238.78.1"="136.238.78.254";       #Vlan701   
"10.10.68.1"="10.10.68.254";           #Vlan1305  
"10.10.69.1"="10.10.69.254";           #Vlan1306  
"10.10.70.1"="10.10.70.254";           #Vlan1307  
"10.10.71.1"="10.10.71.14";            #Vlan1308  
"10.10.152.1"="10.10.152.254";         #Vlan1309  
"10.10.153.1"="10.10.153.254";         #Vlan1310  
"10.10.128.1"="10.10.128.254";         #Vlan1311  
"10.10.136.1"="10.10.136.254";         #Vlan1312  
"10.10.144.1"="10.10.144.254";         #Vlan1313  
"10.10.96.1"="10.10.97.254";           #Vlan1100  
"10.10.100.1"="10.10.101.254";         #Vlan1101
"10.10.192.1"="10.10.192.254";         #Vlan721 / new 07.10.2016
"10.10.193.1"="10.10.193.254";         #Vlan722 / new 07.10.2016
"10.10.194.1"="10.10.194.254";         #Vlan723 / new 07.10.2016
"10.10.41.1"="10.10.41.254";           #Vlan703 / new 17.11.2016
"10.10.122.1"="10.10.122.254";         #Vlan728 / new 02.05.2017
"10.10.123.1"="10.10.123.254";         #Vlan729 / new 02.05.2017
"10.10.124.1"="10.10.124.254";         #Vlan730 / new 03.05.2017
"10.10.73.1"="10.10.73.254";           #Vlan732 / new 06.06.2017
"10.10.42.1"="10.10.42.254";           #Vlan733 / new 06.06.2017
"10.10.43.1"="10.10.43.254";           #Vlan734 / new 06.06.2017
"10.10.38.1"="10.10.38.254";           #Vlan735 / new 30.06.2017
"10.10.39.1"="10.10.39.254";           #Vlan736 / new 28.06.2017


  
"10.23.1.1"="10.23.1.254";             #Vlan3101-DMZ
"10.23.2.1"="10.23.2.254";             #Vlan3102-DMZ
"10.23.3.1"="10.23.3.254";             #Vlan3103-DMZ
"10.24.1.1"="10.24.1.254";             #Vlan3201-DMZ
"10.24.2.1"="10.24.2.254";             #Vlan3202-DMZ
"10.24.3.1"="10.24.3.254";             #Vlan3203-DMZ
"10.24.4.1"="10.24.4.254";             #Vlan3204-DMZ
"10.10.28.1"="10.10.31.254";           #Vlan14-DMZ
}


#Specify the general specs for the destination networks
#-------------------------------------------------------------------------------
#1. Route. HDB hosting services, incl NetBackup Master MetaData/Replica
$DEST1 = "10.10.164.0"
$MASK1 = "255.255.252.0"
#2. Route. HDB shared services, e.g. Archive/Centera
$DEST2 = "193.223.33.192"
$MASK2 = "255.255.255.224"
#3. Route. HDB shared services, e.g. Archive/Centera
$DEST3 = "171.25.64.64"
$MASK3 = "255.255.255.224"
#4. Route. Backup Mediaserver Datacenter
$DEST4 = "10.10.155.0"
$MASK4 = "255.255.255.128"
#5. Route. VxBlock vCenter
$DEST5 = "138.190.224.96"
$MASK5 = "255.255.255.224"
#6. Route. VxBlock  ViPR
$DEST6 = "138.190.224.64"
$MASK6 = "255.255.255.224"
#7. Route. SQL Dump Server QUAL1
$DEST7 = "10.10.65.128"
$MASK7 = "255.255.255.255"
#8. Route. SQL Dump Server QUAL2
$DEST8 = "10.10.65.129"
$MASK8 = "255.255.255.255"
#9. Route. SQL Dump Server PROD1
$DEST9 = "10.10.65.138"
$MASK9 = "255.255.255.255"
#10. Route. SQL Dump Server PROD2
$DEST10 = "10.10.65.137"
$MASK10 = "255.255.255.255"
#11. Route. Backup Mediaserver DMZ
$DEST11 = "10.10.155.128"
$MASK11 = "255.255.255.128"
#-------------------------------------------------------------------------------


####### DO NOT CHANGE BELOW #######
#-------------------------------------------------------------------------------
#Get the current default gateway and compare it with the table above. Set the gateway for the route
$CurrentDG = (Get-wmiObject Win32_networkAdapterConfiguration | where-object {$_.IPEnabled -and $_.DefaultIPGateway -notlike $Null} | select DefaultIPGateway -first 1).DefaultIPGateway
$GW = $GWTable."$CurrentDG"

#1. Routes that should apply to all servers
if ($GW) {
route ADD $DEST1 MASK $MASK1 $GW
route ADD $DEST2 MASK $MASK2 $GW
route ADD $DEST3 MASK $MASK3 $GW
route ADD $DEST4 MASK $MASK4 $GW
route ADD $DEST5 MASK $MASK5 $GW
route ADD $DEST6 MASK $MASK6 $GW
route ADD $DEST11 MASK $MASK11 $GW
}

#2. SQL Dump Routes that should apply to SQL servers EXCEPT for Servers that have 10.10.65.1 as Default Gateway)
if ($GW -and $CurrentDG -notlike "10.10.65.1" -and ([environment]::GetEnvironmentVariable("SQLNUBESROUTE","MACHINE")) -like "1") {
route ADD $DEST7 MASK $MASK7 $GW
route ADD $DEST8 MASK $MASK8 $GW
route ADD $DEST9 MASK $MASK9 $GW
route ADD $DEST10 MASK $MASK10 $GW
}
# Export Routing-Table to C:\Temp as FLG file to query via LD Reports
Write-output (route print -4) >C:\temp\SHH_SRV-STATICROUTE01.FLG
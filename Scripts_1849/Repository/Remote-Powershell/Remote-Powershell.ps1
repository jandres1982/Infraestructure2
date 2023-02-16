#This check the port SMB for those remote servers.
#'shhwsr0958','shhwsr1849' | foreach {Test-NetConnection -ComputerName $_ -CommonTCPPort SMB}  

#This check the port 53 (DNS) for those remote servers
#'shhwsr0958','shhwsrdc1005' | foreach {Test-NetConnection -ComputerName $_ -port 53}
#Only getting true or false --->
#'shhwsr0958','shhwsrdc1005' | foreach {Test-NetConnection -ComputerName $_ -port 53 -InformationLevel Quiet -WarningAction SilentlyContinue} 


#Getting help
#help Test-NetConnection -Parameter Computername

#Checking a web page:
#Test-NetConnection -ComputerName "myaccess.schindler.com" -CommonTCPPort HTTP -InformationLevel Detailed

#CheckingDNS
#Resolve-DnsName servertweap.global.schindler.com |select *
#Resolve-DnsName shhwsr0958.global.schindler.com -DnsOnly
#servertweap.global.schindler.c CNAME  3600  Answer     shhwsr0004.global.schindler.com                                 

#Service restarting example
#Get-Service -name BITS -ComputerName shhwsr0958,shhwsr1848 | Restart-Service -force -PassThru | select machinename,status,displayname 

#Process
#Get-Process lsass -ComputerName shhwsr0958,shhwsr1848 | select machinename,id,name,handles,VM,WS | sort handles,machinename -Descending | Format-Table



#Using EventLog in Powershell
#$EventID  = "2000"
#Clear-Host
#$Machine = "Shhwsrcx0151"
#Get-Eventlog -Logname Application -ComputerName $Machine -After "Tuesday, February 25, 2020 11:02:06 AM" -Before "Wednesday, February 26, 2020 11:02:06 AM" |
#Where-Object {$_.EventID -eq $EventID} | Select-Object -Property ReplacementStrings

##| Format-Table MachineName, Source, EventID -auto
#Get-ADComputer -Filter * -SearchBase "OU=AEU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com" -Properties *  |
#Select -Property Name,DNSHostName,Enabled,LastLogonDate | 
#Export-CSV "C:\tstglobal_Servers.csv" -NoTypeInformation -Encoding UTF8

 #tstglobal.schindler.com/NBI12/Servers/AEU/
 #OU=AEU,OU=Servers,OU=NBI12,DC=tstglobal,DC=schindler,DC=com

Get-ADComputer -Filter * -SearchBase "OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" | select name |  Where-Object { $_.Name -like '*SHH*' } | Export-CSV "D:\Repository\Working\Antonio\Get_Local_Admins\Servers_SHH.txt" -NoTypeInformation -Encoding UTF8

Measure-Object

Export-CSV "C:\global_Servers_clean.csv" -NoTypeInformation -Encoding UTF8
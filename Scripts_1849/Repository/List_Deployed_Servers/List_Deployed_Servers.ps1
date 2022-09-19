
$textDate = '09/01/2017' #Starting Searching Date month/day/year
$Total_Days = 5 #Number of total days to check after the starting date.

$startDate = ([datetime]$textDate).Date
$endDate = $startDate.AddDays($Total_Days)

Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'SHH' > 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'CRD' >> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'SCH'>> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'MAN'>> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'INF'>> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'ASZ'>> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'
Get-ADComputer -Filter 'whenCreated -ge $startDate -and whenCreated -lt $endDate' -Properties whenCreated | 
Select-Object -Property SamAccountName,whenCreated | findstr 'WSR'| findstr 'TRD'>> 'D:\Repository\Working\Antonio\List_Deployed_Servers\Server_List.txt'

#Depending on the Prestage the date can't be slightly different to the stagging date, for that reason I recommend to sort the list and check for the first servers installation date and be sure they are inside the filter required.

#gcim Win32_OperatingSystem | select Version, InstallDate, OSArchitecture #check installation date


#([WMI]””).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate)
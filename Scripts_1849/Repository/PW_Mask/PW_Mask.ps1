
#Defining the account administrator built in:
$Accounts = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" #Check local admin accounts
$Admin_Sid = $Accounts.sid | Select-String "-500" #Take the one with 0500
$Admin_account = (New-Object System.Security.Principal.SecurityIdentifier($Admin_Sid)).Translate([System.Security.Principal.NTAccount]).value #Take the name related to the 0500
$Split = $Admin_account.Split('\') #Split btw Hostname and the admin account
$Administrator = $Split[1]
$Hostname = $Split[0]


############################################

#
#
#
$length = $Hostname.Length #Checking how long is
$Lastsub = $Hostname.Substring($length-1) #Take the last digit of the hostname this must be a number
#
#
#

$Firstsub = $hostname.Substring(0,1) #Takes the first digit of the hostname, this have to be a letter and goes to upper case
$Firstsub_up = $Firstsub.toUpper()
#

#Comienza a contar a partir de la 2 posición (sin incluir) y dame 1 que venga luego.
$Middlesub = $hostname.Substring(2,1) #This takes the 3rd and goes upper case as well again.
$MiddleUpsub  = $Middlesub.ToUpper()
 
#### Defining PW

$string = "T14Vd"+$Lastsub+"Pw!"+$MiddleUpsub+"4A11$"+$Firstsub_up
$Secure_String_Pwd = ConvertTo-SecureString "$string" -AsPlainText -Force


#########################################################################################

#Defining PW

$Administrator | Set-LocalUser -Password $Secure_String_Pwd

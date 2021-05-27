$function = $arg(0)
$hostname = hostname
$hostname = $hostname.Toupper()
$KG = $hostname.Substring(0,3)
$Description = "$KG Windows Server $function"
$OSWMI=Get-WmiObject -class Win32_OperatingSystem
$OSWMI.Description = $Description
$OSWMI.put()
$Source = Import-Csv -LiteralPath "D:\Repository\Working\Antonio\Azure\AzureGuestAgent\AzureGuestAgent_911.csv"
$Servers = $source."Device Name"

#$AzureGuestAgentVersion = $(Get-WmiObject Win32_Product -ComputerName shhwsr1238 | select Name,Version | Where-Object {$_.name -like "*Azure*Agent*"}).version

foreach ($Server in $Servers)
{

    $AzureGuestAgentVersion = $(Get-WmiObject Win32_Product -ComputerName $Server -ErrorAction SilentlyContinue | select Name,Version | Where-Object {$_.name -like "*Azure*Agent*"}).version

    if ($AzureGuestAgentVersion -eq "2.7.41491.1075")
    {
        Write-Host "AzureGuestAgent Version is correct $server with version $AzureGuestAgentVersion" -ForegroundColor Green
        Write-Output "$server;$AzureGuestAgentVersion" >> "D:\Repository\Working\Antonio\Azure\AzureGuestAgent\AzureGuestAgentReport.txt"
    }else
        {
        Write-Host "AzureGuestAgent Version is wrong or can't be found $server with version $AzureGuestAgentVersion" -ForegroundColor Yellow
        Write-Output "$server;$AzureGuestAgentVersion" >> "D:\Repository\Working\Antonio\Azure\AzureGuestAgent\AzureGuestAgentReport.txt"
        }
        
}
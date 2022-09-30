param (
    [Parameter(Mandatory = $false)]
    [string]$server
)

Write-Host "Working on Server $Server" -ForegroundColor Yellow
Function Remove_WSUS
{
    $WSUS_server = 'shhwsr1238'
    $WSUS_KG_server = 'shhwsr1242'
    $UseSSL = $False
    $Port = 8530
    #Shhwsr1238
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
    $Wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WSUS_server,$UseSSL,$Port)
    $client = $wsus.SearchComputerTargets($server)
    $client[0]
    $client[0].Delete()
    #shhwsr1242
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
    $Wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WSUS_KG_server,$UseSSL,$Port)
    $client = $wsus.SearchComputerTargets($server)
    $client[0]
    $client[0].Delete() 
}

Remove_WSUS
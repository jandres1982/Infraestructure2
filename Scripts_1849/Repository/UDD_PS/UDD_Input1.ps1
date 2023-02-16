Import-Module UniversalDashboard.Community
Get-UDDashboard | Stop-UDDashboard

$Root = $PSScriptRoot
$Init = New-UDEndpointInitialization -Variable "Root"

$Dashboard = New-UDDashboard -Title "Data Input" -Content {
    New-UDInput -Title "Input" -Endpoint {
    param(
    [String]$YourName,[Bool]$Online,[System.DateTime]$date)
   
    

$YourName | Out-File (Join-Path $Root "output.txt")
}
} -EndpointInitialization $init

Start-UDDashboard -Dashboard $Dashboard -AutoReload
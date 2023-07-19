# servidores DHCP donde vamos a buscar las macs
$dhcpServers = @("shhwsr1626")
#$dhcpServers = @("shhwsr1626","shhwsr1628","shhwsr1630","shhwsr1632","shhwsr1841","shhwsr1858","shhwsr1859","shhwsr1872","shhwsr1874","shhwsr1875","shhwsr2038","shhwsr2039") # Define your servers here
$results = @("083a88b6b8ca")
# macs en las reservas a borrar
$clientId =  @("aabbccddeeff","aabbccaabbcc") #10.1.78.218, 1626  10.2.68.218 1628

#para cada mac, busco en cada servidor DHCP en que scope está reservado y lo meto en el objeto Results
foreach ($clientId in $clientId){

 

foreach ($dhcpServer in $dhcpServers) {
    Write-Host "Searching $dhcpServer..."
    Get-DhcpServerv4Scope -ComputerName $dhcpServer | ForEach-Object {
        $results += Get-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $_.ScopeId -ClientId $clientId -ErrorAction SilentlyContinue
    }
    $results | ForEach-Object {$_ | Add-Member -membertype noteproperty -Name Server -Value $dhcpServer -ErrorAction SilentlyContinue}
}
Write-Output  $results  | select Server, IPAddress, ScopeId, ClientId, Name, Description | ft | Out-File -FilePath "D:\$clientId.txt"
#$results.Clear()
}
#para cada entrada de result, que ya contiene unicamente los scopes de cada servidor donde esa mac está reservada, la elimino
foreach ($results in $results) {
    Write-Output -Verbose $results.ScopeId.IPAddressToString
    Write-Output -Verbose $results.ClientID
    Write-Output -Verbose $results.Server
    Remove-DhcpServerv4Reservation -ComputerName $results.Server -ScopeId $results.ScopeId.IPAddressToString -ClientId $results.ClientID
}


# Recorre cada servidor y obten los scopes

 

foreach ($servidor in $servidores) {

 

    Write-Host "Obteniendo los scopes DHCP de $servidor"

 

    $scopes = Get-DhcpServerv4Scope -ComputerName $servidor

 


    # Guarda los datos en un archivo CSV

 

    $archivoSalida = "Scopes_DHCP_$servidor.csv"

 

    $scopes | Export-Csv -Path $archivoSalida -NoTypeInformation

 

}

 


Write-Host "Extracción de scopes DHCP completada."


$dhcp = Get-DhcpServerInDC

foreach ($server in $dhcp.dnsname)
{

if (Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue -Authentication Kerberos)

{

$server >> Dhcp.txt

}

}

$dhcpServer = Get-Content -Path Dhcp.txt


#foreach
$dhcpServer = "shhwsr1632"

Get-DhcpServerv4Scope -ComputerName $dhcpServer
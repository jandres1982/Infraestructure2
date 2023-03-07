$uri = "https://jsonplaceholder.typicode.com/posts"
$query = "?userid=1"
$url = $uri + $query
$peticion = Invoke-WebRequest -Method get -uri $url
$peticion.Content


Connect-AzAccount
$url = "https://graph.microsoft.com/v1.0/me"

$peticion = Invoke-WebRequest -Method get -uri $url

	
Install-Module Microsoft.Graph -Scope AllUsers -Force
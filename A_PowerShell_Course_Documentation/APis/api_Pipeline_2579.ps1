# Define organization base url, PAT and API version variables
$org = "devsdb"
$project= "SIS-Azure_OP-Automation"
$pat = "2iorsurunvakcaqqjdevtggtm23gabou4llrbkm5y4awwvm35ljq"
$id = "1734"
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$url = "https://dev.azure.com/$org/$project/_apis/pipelines/$id/runs?api-version=7.0"

$json = @’
{
“self”: { "refName":"main"},
}
‘@

$response = Invoke-RestMethod -Uri $url -Headers @{Authorization = “Basic $token”} -Method Post -Body $JSON -ContentType application/json
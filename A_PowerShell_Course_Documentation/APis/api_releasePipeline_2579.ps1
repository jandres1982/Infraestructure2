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

#$response = Invoke-RestMethod -Uri $url -Headers @{Authorization = “Basic $token”} -Method Post -Body $JSON -ContentType application/json

#GET https://vsrm.dev.azure.com/{organization}/{project}/_apis/release/releases?definitionId={definitionId}&definitionEnvironmentId={definitionEnvironmentId}&searchText={searchText}&createdBy={createdBy}&statusFilter={statusFilter}&environmentStatusFilter={environmentStatusFilter}&minCreatedTime={minCreatedTime}&maxCreatedTime={maxCreatedTime}&queryOrder={queryOrder}&$top={$top}&continuationToken={continuationToken}&$expand={$expand}&artifactTypeId={artifactTypeId}&sourceId={sourceId}&artifactVersionId={artifactVersionId}&sourceBranchFilter={sourceBranchFilter}&isDeleted={isDeleted}&tagFilter={tagFilter}&propertyFilters={propertyFilters}&releaseIdFilter={releaseIdFilter}&path={path}&api-version=6.1-preview.8
#$url = "https://vsrm.dev.azure.com/$org/$project/_apis/release/releases?api-version=6.1-preview.8"

#Release Pipeline:
$url = "https://vsrm.dev.azure.com/$org/$project/_apis/release/definitions?api-version=6.1-preview.4"
$response = Invoke-RestMethod -Uri $url -Headers @{Authorization = “Basic $token”} -Method Get -ContentType application/json
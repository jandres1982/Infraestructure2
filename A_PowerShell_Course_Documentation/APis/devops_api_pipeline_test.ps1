https://dev.azure.com/devsdb/SIS-IOC-Azure/_releaseDefinition?definitionId=281&_a=definition-tasks&environmentId=486


$updateReleaseUri = "$($vrsmBaseUri)_apis/Release/releases/$($releaseId)/environments/$($environmentId)?api-version=6.0-preview"
$updateReleaseJsonBody = @{status = 'inProgress' }
$updateReleaseJsonBody = $updateReleaseJsonBody | ConvertTo-Json -Depth 100

PATCH https://vsrm.dev.azure.com/devsdb/SIS-IOC-Azure/_apis/Release/releases/281/environments/486?api-version=6.0-preview.6
#PATCH https://vsrm.dev.azure.com/{organization}/{project}/_apis/Release/releases/{releaseId}/environments/{environmentId}?api-version=6.0-preview.6

{
  "status": "inProgress",
  "scheduledDeploymentTime": null,
  "comment": null,
  "variables": {}
}

{
  "status": "inProgress",
  "scheduledDeploymentTime": null,
  "comment": null,
  "variables": {}
}


Invoke-RestMethod -


$token = "lbivwvgk47bqvdohdkynady3u5mq6ipejrw5jx5ti3zjfvyp4aha"
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$token"))
$ORGANIZATION = "devsdb"
$PROJECT = "SIS-IOC-Azure"
$id = "599"

$reqParams = @{
"URI" = "https://dev.azure.com/$ORGANIZATION/$PROJECT/_apis/pipelines/$id/runs?api-version=7.0";
"Method" = "POST";
"Headers" = @{
    "Authorization" = "Basic "+ $token;
    "Content-Type" = "application/json";
    "Accept" = "application/json";
};
"Body" = @{
    "resources" =  @{
        "repositories" = @{
            "self" = @{
                "refName"= "refs/heads/master"
            }
        }
    }
} | ConvertTo-Json -Depth 5;
}

Invoke-WebRequest @reqParams
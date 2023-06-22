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
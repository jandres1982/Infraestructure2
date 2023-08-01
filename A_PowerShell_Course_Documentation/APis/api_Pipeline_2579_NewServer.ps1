# Replace these variables with your actual values
$organizationUrl = "https://dev.azure.com/devsdb"
$projectName = "SIS-Azure_OP-Automation"
$personalAccessToken = "2iorsurunvakcaqqjdevtggtm23gabou4llrbkm5y4awwvm35ljq"
$pipelineId = "1764"
$varname1 = "vm"
$varvalue1 = "zzzwsr0012"
$varname2 = "domain"
$varvalue2 = "global"

# Define the API endpoint
$apiUrl = "$organizationUrl/$projectName/_apis/pipelines/$pipelineId/runs?api-version=6.0-preview.1"

# Create a JSON payload for the request with variables
$variables = @{
    variables = @{
                ($varname1) = @{
            value = $varvalue1
        }
                ($varname2) = @{
            value = $varvalue2
        }
    }
}

$payload = ConvertTo-Json $variables

# Make the API request to trigger the pipeline run with variables
$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
} -ContentType "application/json" -Body $payload

# Output the response
$response
# Replace these variables with your actual values
$organizationUrl = "https://dev.azure.com/devsdb"
$projectName = "SIS-Azure_OP-Automation"
$personalAccessToken = "2iorsurunvakcaqqjdevtggtm23gabou4llrbkm5y4awwvm35ljq"
$pipelineId = "1734"
$varname1 = "vm"
$varvalue1 = "zzzwsr0999"
$varname2 = "mac"
$varvalue2 = "zzzwsr0999"
$varname3 = "osversion"
$varvalue3 = "2019"
$varname4 = "function"
$varvalue4 = "test server devops api"


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
                ($varname3) = @{
            value = $varvalue3
        }
                ($varname4) = @{
            value = $varvalue4
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
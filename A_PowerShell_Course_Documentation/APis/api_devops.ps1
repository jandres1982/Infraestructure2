$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":hbk7csaf5h7xxm3abunvttarryvr22ugkhayu76bcutdfz3uvkeq"))
#$token = "hbk7csaf5h7xxm3abunvttarryvr22ugkhayu76bcutdfz3uvkeq"
$ORGANIZATION = "devsdb"
$PROJECT = "SIS-IOC-Azure"
$Pipeline_id = "599"

#https://dev.azure.com/devsdb/SIS-IOC-Azure/_releaseDefinition?definitionId=114&_a=environments-editor-preview
#POST https://dev.azure.com/{organization}/{project}/_apis/pipelines/{pipelineId}/runs?api-version=7.1-preview.1
#POST https://vsrm.dev.azure.com/{organization}/{project}/_apis/release/releases?api-version=7.0
$reqParams = @{
"URI" = "https://dev.azure.com/$ORGANIZATION/$PROJECT/_apis/pipelines/$Pipeline_id/runs?api-version=7.0";
"Method" = "POST";
"Headers" = @{
    "Authorization" = "Basic "+ $token;
    "Content-Type" = "application/json";
    "Accept" = "application/json";
};
"Body" = @{
    "previewRun" = $false;
};

}

$info = Invoke-WebRequest @reqParams

#https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run-pipeline?view=azure-devops-rest-7.1

#wpf
#visual studio community edition
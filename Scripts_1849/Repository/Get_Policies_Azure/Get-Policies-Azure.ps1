Get-AzPolicyAssignment -Id '/providers/Microsoft.Management/managementGroups/mgmtgr-sis-global/providers/Microsoft.Authorization/policyAssignments/5da4014ff1214ff9b5aea8f3'

Get-RetentionCompliancePolicy -Identity "Allowed virtual machine size SKUs"

$(Get-AzPolicyStateSummary).PolicyAssignments



#policy definition
Get-AzPolicyDefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'

Get-AzPolicySetDefinition -id '/providers/Microsoft.Management/managementGroups/mgmtgr-sis-global/providers/Microsoft.Authorization/policySetDefinitions/ea36565ae5934c8bb2606aa2'
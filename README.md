# Scripts to create and remove log search alerts in Microsoft Azure

### To create a new log search alert:

```
New-LogSearchAlert -opResourceGroupName "MyOperationalInsightsResourceGroup" -actionResourceGroupName "MyResourceGroup" -ruleName "MyRule" -searchQuery "My azure activity search query" -workspaceName "MyOperationalInsightsWorkspaceName" -actionGroup "MyActionGroupName"
```

There are more optional parameters detailed in the Powershell script.


### To delete a log search alert:

```
Remove-LogSearchAlert -opResourceGroupName "MyOperationalInsightsResourceGroup" -ruleName "MyRule"
```
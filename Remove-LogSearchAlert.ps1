Function Remove-LogSearchAlert{
    <#
      .SYNOPSIS
        Removes a Log Searh Alert
     
      .DESCRIPTION 
        Removes a Log Search Alert
  
      .PARAMETER subscriptionId
        The ID of the Azure Subscription
  
      .PARAMETER resourceGroupName
        The name of the resource group in which the alert resides
             
      .EXAMPLE
        C:\PS> Remove-LogSearchAlert -opResourceGroupName "MyOperationalInsightsResourceGroup" -ruleName "MyRule"
    
    #>
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$True, HelpMessage='The resource group for the Operational Insights Workspace')]
      [string]$opResourceGroupName,
      [Parameter(Mandatory=$True, HelpMessage='Name of the alert rule')]
      [string]$ruleName
      )
      
      #check if alert rule exists
      $rule = Get-AzScheduledQueryRule -ResourceGroupName $opResourceGroupName -Name $ruleName -ErrorAction SilentlyContinue
 
      if ($rule) {
        Write-Output "Deleting alert rule: $ruleName"
        Remove-AzScheduledQueryRule -ResourceGroupName $opResourceGroupName -Name $ruleName
 
      } else {
        Write-Output "Alert rule: $ruleName could not be found"
  
      }
  }
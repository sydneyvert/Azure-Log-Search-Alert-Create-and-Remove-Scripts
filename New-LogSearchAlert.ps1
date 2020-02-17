Function New-LogSearchAlert{
    <#
      .SYNOPSIS
        Creates a Log Search Alert
     
      .DESCRIPTION 
        Creates a Log Search Alert
  
      .PARAMETER resourceGroupName
        The name of the resource group in which the alert resides
             
      .EXAMPLE
        C:\PS> New-LogSearchAlert -opResourceGroupName "MyOperationalInsightsResourceGroup" -actionResourceGroupName "MyResourceGroup" -ruleName "MyRule" -searchQuery "My azure activity search query" -workspaceName "MyOperationalInsightsWorkspaceName" -actionGroup "MyActionGroupName"
    #>
    
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$True, HelpMessage='The resource group for the Operational Insights Workspace')]
      [string]$opResourceGroupName,
      [Parameter(Mandatory=$True, HelpMessage='The resource group name for the Action Group')]
      [string]$actionResourceGroupName,
      [Parameter(Mandatory=$True, HelpMessage='Name of the alert rule')]
      [string]$ruleName,
      [Parameter(Mandatory=$True, HelpMessage='Search query')]
      [string]$searchQuery,
      [Parameter(Mandatory=$True, HelpMessage='Operational Insights Workspace Name')]
      [string]$workspaceName,
      [Parameter(Mandatory=$True, HelpMessage='Action Group')]
      [string]$actionGroupName,
      [Parameter(Mandatory=$False, HelpMessage='0, 1, 2, 3 or 4')]
      [string]$severity = "1",
      [Parameter(Mandatory=$False, HelpMessage='Search Description')]
      [string]$searchDescription = "Saved Search",
      [Parameter(Mandatory=$False, HelpMessage='Custom Email Subject')]
      [string]$customEmailSubject = "Log Search Azure Alert",
      [Parameter(Mandatory=$False, HelpMessage='Schedule interval in minutes')]
      [string]$scheduleInterval = 5,
      [Parameter(Mandatory=$False, HelpMessage='Schedule query time span in minutes')]
      [string]$scheduleTimeSpan = 5,
      [Parameter(Mandatory=$False, HelpMessage='Threshold operator, e.g. lt, gt')]
      [string]$thresholdOperator = "GreaterThan",
      [Parameter(Mandatory=$False, HelpMessage='Threshold value as integer')]
      [string]$thresholdValue = 0,
      [Parameter(Mandatory=$False, HelpMessage='Throttling duration in minutes, disabled by default')]
      [string]$throttlingDuration = 0,
      [Parameter(Mandatory=$False, HelpMessage='Location e.g. westeurope')]
      [string]$location = "mylocation"
      )
      
      #check to see if the alert rule already exists
      $rule = Get-AzScheduledQueryRule -ResourceGroupName $opResourceGroupName -Name $ruleName -ErrorAction SilentlyContinue
  
      if ($rule) {
        Write-Output "Alert rule $ruleName already exists"
      
      } else {
        Write-Output "Creating alert rule $ruleName"
        $workspace = Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $opResourceGroupName
  
        #create the search query
        $source = New-AzScheduledQueryRuleSource -Query $searchQuery -DataSourceId $workspace.resourceid
  
        #create schedule
        $schedule = New-AzScheduledQueryRuleSchedule -FrequencyInMinutes $scheduleInterval -TimeWindowInMinutes $scheduleTimeSpan
  
        #create trigger
        $triggerCondition = New-AzScheduledQueryRuleTriggerCondition -ThresholdOperator $thresholdOperator -Threshold $thresholdValue
  
        #put action group into the correct form
        $actionGroup = Get-AzActionGroup -ResourceGroupName $actionResourceGroupName -Name $actionGroupName
        $aznsActionGroup = New-AzScheduledQueryRuleAznsActionGroup -ActionGroup $actionGroup.id -EmailSubject $customEmailSubject
  
        #create the action for the alert
        $alertingAction = New-AzScheduledQueryRuleAlertingAction -AznsAction $aznsActionGroup -Severity $severity -Trigger $triggerCondition -ThrottlingInMinutes $throttlingDuration
  
        try {
          #create alert rule using New-AzScheduledQueryRule
          New-AzScheduledQueryRule -ResourceGroupName $opResourceGroupName -Location $location -Action $alertingAction -Enabled $true -Schedule $schedule -Source $source -Name $ruleName
        
        } catch {
          Write-Error "Alert rule $ruleName could not be created"
        }
  
      }
  }